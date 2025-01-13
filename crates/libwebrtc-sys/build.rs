#![warn(
    clippy::allow_attributes,
    clippy::allow_attributes_without_reason,
    clippy::pedantic
)]

#[cfg(not(target_os = "windows"))]
use std::ffi::OsString;
#[cfg(target_os = "macos")]
use std::process;
use std::{
    env, fs,
    fs::File,
    io::{BufReader, BufWriter, Read, Write},
    path::{Path, PathBuf},
    process::Command,
};

use anyhow::bail;
use flate2::read::GzDecoder;
use sha2::{Digest, Sha256};
use tar::Archive;
use walkdir::{DirEntry, WalkDir};

/// Base URL for the [`libwebrtc-bin`] GitHub release.
///
/// [`libwebrtc-bin`]: https://github.com/instrumentisto/libwebrtc-bin
static LIBWEBRTC_URL: &str =
    "https://github.com/instrumentisto/libwebrtc-bin/releases/download\
                                                    /131.0.6778.264";

/// URL for downloading `openal-soft` source code.
static OPENAL_URL: &str =
    "https://github.com/kcat/openal-soft/archive/refs/tags/1.24.1";

fn main() -> anyhow::Result<()> {
    let lib_dir = libpath()?;
    if lib_dir.exists() {
        fs::create_dir_all(&lib_dir)?;
    }
    download_libwebrtc()?;
    compile_openal()?;

    let path = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?);
    let libpath = libpath()?;
    let cpp_files = get_cpp_files()?;

    println!("cargo:rustc-link-lib=webrtc");

    link_libs()?;

    let mut build = cxx_build::bridge("src/bridge.rs");
    build
        .files(&cpp_files)
        .include(path.join("include"))
        .include(libpath.join("include"))
        .include(libpath.join("include/third_party/abseil-cpp"))
        .include(libpath.join("include/third_party/libyuv/include"))
        .flag("-DNOMINMAX");

    #[cfg(target_os = "windows")]
    build.flag("-DNDEBUG");
    #[cfg(not(target_os = "windows"))]
    if env::var_os("PROFILE") == Some(OsString::from("release")) {
        build.flag("-DNDEBUG");
    }

    #[cfg(target_os = "linux")]
    {
        build
            .flag("-DWEBRTC_LINUX")
            .flag("-DWEBRTC_POSIX")
            .flag("-DWEBRTC_USE_X11")
            .flag("-std=c++17");
    }
    #[cfg(target_os = "macos")]
    {
        println!("cargo:rustc-env=MACOSX_DEPLOYMENT_TARGET=10.11");
        build
            .include(libpath.join("include/sdk/objc/base"))
            .include(libpath.join("include/sdk/objc"));
        build
            .flag("-DWEBRTC_POSIX")
            .flag("-DWEBRTC_MAC")
            .flag("-DWEBRTC_ENABLE_OBJC_SYMBOL_EXPORT")
            .flag("-DWEBRTC_LIBRARY_IMPL")
            .flag("-std=c++17")
            .flag("-objC")
            .flag("-fobjc-arc");
    }
    #[cfg(target_os = "windows")]
    {
        println!("cargo:rustc-link-lib=OpenAL32");
        build.flag("-DWEBRTC_WIN").flag("/std:c++20");
    }

    #[cfg(feature = "fake-media")]
    {
        build.flag("-DFAKE_MEDIA");
    }

    build.compile("libwebrtc-sys");

    for file in cpp_files {
        println!("cargo:rerun-if-changed={}", file.display());
    }
    get_header_files()?.into_iter().for_each(|file| {
        println!("cargo:rerun-if-changed={}", file.display());
    });
    println!("cargo:rerun-if-changed=src/bridge.rs");
    println!("cargo:rerun-if-changed=./lib");
    println!("cargo:rerun-if-env-changed=INSTALL_WEBRTC");
    println!("cargo:rerun-if-env-changed=INSTALL_OPENAL");

    Ok(())
}

/// Returns target architecture to build the library for.
fn get_target() -> anyhow::Result<String> {
    env::var("TARGET").map_err(Into::into)
}

/// Returns expected `libwebrtc` archives SHA-256 hashes.
fn get_expected_libwebrtc_hash() -> anyhow::Result<&'static str> {
    Ok(match get_target()?.as_str() {
        "aarch64-unknown-linux-gnu" => {
            "288cde042e429e53240e7859d4b7c7f54b24f8ced6f82127b312feb4b2bec92f"
        }
        "x86_64-unknown-linux-gnu" => {
            "fa9723606aa5cb7bc63ceb8a1ed264e2c73508a8e9a8a167f6493810427137e9"
        }
        "aarch64-apple-darwin" => {
            "860205dd9a555b38113abc6dc250d5f4c032c82886175f6307f31fbea2d8b0e3"
        }
        "x86_64-apple-darwin" => {
            "08b8aa369d2798aeb987bbde010739b7292e7e8df912dfc907f19a7be6f4e6ac"
        }
        "x86_64-pc-windows-msvc" => {
            "2ffa419baba47572b0e7ddaf2dce52ceef488c2ece1cd8550e349561b31eb02c"
        }
        arch => return Err(anyhow::anyhow!("Unsupported target: {arch}")),
    })
}

/// Returns [`PathBuf`] to the directory containing the library.
fn libpath() -> anyhow::Result<PathBuf> {
    let target = get_target()?;
    let manifest_path = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?);
    Ok(manifest_path.join("lib").join(target))
}

/// Recursively copies `src` directory to the provided `dst` [`Path`].
fn copy_dir_all(
    src: impl AsRef<Path>,
    dst: impl AsRef<Path>,
) -> anyhow::Result<()> {
    fs::create_dir_all(&dst)?;
    for entry in fs::read_dir(src)? {
        let entry = entry?;
        let ty = entry.file_type()?;
        if ty.is_dir() {
            copy_dir_all(entry.path(), dst.as_ref().join(entry.file_name()))?;
        } else {
            fs::copy(entry.path(), dst.as_ref().join(entry.file_name()))?;
        }
    }
    Ok(())
}

/// Returns a [`PathBuf`] to the OpenAL dynamic library destination within
/// Flutter files.
fn get_path_to_openal() -> anyhow::Result<PathBuf> {
    let mut workspace_path = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?);
    workspace_path.pop();
    workspace_path.pop();

    Ok(match get_target()?.as_str() {
        "aarch64-apple-darwin" | "x86_64-apple-darwin" => {
            workspace_path.join("macos").join("rust").join("lib")
        }
        "x86_64-unknown-linux-gnu" => workspace_path
            .join("linux")
            .join("rust")
            .join("lib")
            .join(get_target()?.as_str()),
        "x86_64-pc-windows-msvc" => workspace_path
            .join("windows")
            .join("rust")
            .join("lib")
            .join(get_target()?.as_str()),
        _ => return Err(anyhow::anyhow!("Platform isn't supported")),
    })
}

/// Downloads and compiles OpenAL dynamic library.
///
/// Copies OpenAL headers and compiled library to the required locations.
#[expect(clippy::too_many_lines, reason = "not matters here")]
fn compile_openal() -> anyhow::Result<()> {
    let openal_version = OPENAL_URL.split('/').last().unwrap();
    let manifest_path = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?);
    let temp_dir = manifest_path.join("temp");
    let openal_path = get_path_to_openal()?;

    let archive = temp_dir.join(format!("{openal_version}.tar.gz"));

    let is_already_installed = fs::metadata(
        manifest_path
            .join("lib")
            .join(get_target()?.as_str())
            .join("include")
            .join("AL"),
    )
    .is_ok();
    let is_install_openal =
        env::var("INSTALL_OPENAL").as_deref().unwrap_or("0") == "0";

    if is_install_openal && is_already_installed {
        return Ok(());
    }

    if temp_dir.exists() {
        fs::remove_dir_all(&temp_dir)?;
    }
    fs::create_dir_all(&temp_dir)?;

    {
        let mut resp = BufReader::new(reqwest::blocking::get(format!(
            "{OPENAL_URL}/{openal_version}.tar.gz",
        ))?);
        let mut out_file = BufWriter::new(File::create(&archive)?);

        let mut buffer = [0; 512];
        loop {
            let count = resp.read(&mut buffer)?;
            if count == 0 {
                break;
            };
            _ = out_file.write(&buffer[0..count])?;
        }
    }

    let mut archive = Archive::new(GzDecoder::new(File::open(archive)?));
    archive.unpack(&temp_dir)?;

    let openal_src_path =
        temp_dir.join(format!("openal-soft-{openal_version}"));

    copy_dir_all(
        openal_src_path.join("include"),
        manifest_path
            .join("lib")
            .join(get_target()?.as_str())
            .join("include"),
    )
    .unwrap();

    let mut cmake_cmd = Command::new("cmake");
    cmake_cmd.current_dir(&openal_src_path).args([
        ".",
        ".",
        "-DCMAKE_BUILD_TYPE=Release",
    ]);
    #[cfg(target_os = "macos")]
    cmake_cmd.arg("-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64");
    drop(cmake_cmd.output()?);

    drop(
        Command::new("cmake")
            .current_dir(&openal_src_path)
            .args(["--build", ".", "--config", "Release"])
            .output()?,
    );

    fs::create_dir_all(&openal_path)?;

    match get_target()?.as_str() {
        "aarch64-apple-darwin" | "x86_64-apple-darwin" => {
            fs::copy(
                openal_src_path.join("libopenal.dylib"),
                openal_path.join("libopenal.1.dylib"),
            )?;
        }
        "x86_64-unknown-linux-gnu" => {
            _ = Command::new("strip")
                .arg("libopenal.so.1")
                .current_dir(&openal_src_path)
                .output()?;
            fs::copy(
                openal_src_path.join("libopenal.so.1"),
                openal_path.join("libopenal.so.1"),
            )?;
        }
        "x86_64-pc-windows-msvc" => {
            fs::copy(
                openal_src_path.join("Release").join("OpenAL32.dll"),
                openal_path.join("OpenAL32.dll"),
            )?;
            fs::copy(
                openal_src_path.join("Release").join("OpenAL32.lib"),
                openal_path.join("OpenAL32.lib"),
            )?;
            let path = manifest_path
                .join("lib")
                .join(get_target()?.as_str())
                .join("release")
                .join("OpenAL32.lib");
            fs::copy(
                openal_src_path.join("Release").join("OpenAL32.lib"),
                path,
            )?;
        }
        _ => (),
    }

    fs::remove_dir_all(&temp_dir)?;

    Ok(())
}

/// Downloads and unpacks compiled `libwebrtc` library.
fn download_libwebrtc() -> anyhow::Result<()> {
    let manifest_path = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?);
    let temp_dir = manifest_path.join("temp");
    let lib_dir = libpath()?;

    let tar_file = {
        let mut name = String::from("libwebrtc-");

        #[cfg(target_os = "windows")]
        name.push_str("windows-x64.tar.gz");
        #[cfg(target_os = "linux")]
        name.push_str("linux-x64.tar.gz");

        match get_target()?.as_str() {
            "aarch64-apple-darwin" => {
                name.push_str("macos-arm64.tar.gz");
            }
            "x86_64-apple-darwin" => {
                name.push_str("macos-x64.tar.gz");
            }
            _ => (),
        }

        name
    };
    let archive = temp_dir.join(&tar_file);
    let checksum = lib_dir.join("CHECKSUM");
    let expected_hash = get_expected_libwebrtc_hash()?;

    // Force download if `INSTALL_WEBRTC=1`.
    if env::var("INSTALL_WEBRTC").as_deref().unwrap_or("0") == "0" {
        // Skip download if already downloaded and checksum matches.
        if fs::metadata(&lib_dir).is_ok_and(|m| m.is_dir())
            && fs::read(&checksum).unwrap_or_default().as_slice()
                == expected_hash.as_bytes()
        {
            return Ok(());
        }
    }

    // Clean up `temp` directory.
    if temp_dir.exists() {
        fs::remove_dir_all(&temp_dir)?;
    }
    fs::create_dir_all(&temp_dir)?;

    // Download the compiled `libwebrtc` archive.
    {
        let mut resp = BufReader::new(reqwest::blocking::get(format!(
            "{LIBWEBRTC_URL}/{tar_file}"
        ))?);
        let mut out_file = BufWriter::new(fs::File::create(&archive)?);
        let mut hasher = Sha256::new();

        let mut buffer = [0; 512];
        loop {
            let count = resp.read(&mut buffer)?;
            if count == 0 {
                break;
            };
            hasher.update(&buffer[0..count]);
            _ = out_file.write(&buffer[0..count])?;
        }

        if format!("{:x}", hasher.finalize()) != expected_hash {
            bail!("SHA-256 checksum doesn't match");
        }
    }

    // Unpack the downloaded `libwebrtc` archive.
    let mut archive = Archive::new(GzDecoder::new(File::open(archive)?));
    archive.unpack(lib_dir)?;

    // Clean up the downloaded `libwebrtc` archive.
    fs::remove_dir_all(&temp_dir)?;

    // Write the downloaded checksum.
    fs::write(&checksum, expected_hash).map_err(Into::into)
}

/// Returns a list of all C++ sources that should be compiled.
fn get_cpp_files() -> anyhow::Result<Vec<PathBuf>> {
    let dir = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?)
        .join("src")
        .join("cpp");

    #[cfg_attr(target_os = "macos", expect(unused_mut, reason = "cfg"))]
    let mut files = get_files_from_dir(dir);

    #[cfg(not(target_os = "macos"))]
    files.retain(|e| !e.to_str().unwrap().contains(".mm"));

    Ok(files)
}

/// Returns a list of all header files that should be included.
fn get_header_files() -> anyhow::Result<Vec<PathBuf>> {
    let dir = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?).join("include");

    Ok(get_files_from_dir(dir))
}

/// Performs recursive directory traversal returning all the found files.
fn get_files_from_dir<P: AsRef<Path>>(dir: P) -> Vec<PathBuf> {
    WalkDir::new(dir)
        .into_iter()
        .filter_map(Result::ok)
        .filter(|e| e.file_type().is_file())
        .map(DirEntry::into_path)
        .collect()
}

/// Emits all the required `rustc-link-lib` instructions.
fn link_libs() -> anyhow::Result<()> {
    let target = get_target()?;
    #[cfg(target_os = "linux")]
    {
        for dep in [
            "x11",
            "xfixes",
            "xdamage",
            "xext",
            "xtst",
            "xrandr",
            "xcomposite",
        ] {
            pkg_config::Config::new().probe(dep).unwrap();
        }
        match env::var("PROFILE").unwrap().as_str() {
            "debug" => {
                println!(
                    "cargo:rustc-link-search=\
                     native=crates/libwebrtc-sys/lib/{target}/debug/",
                );
            }
            "release" => {
                println!(
                    "cargo:rustc-link-search=\
                     native=crates/libwebrtc-sys/lib/{target}/release/",
                );
            }
            _ => unreachable!(),
        }
    }
    #[cfg(target_os = "macos")]
    {
        for framework in [
            "AudioUnit",
            "CoreServices",
            "CoreFoundation",
            "AudioToolbox",
            "CoreGraphics",
            "CoreAudio",
            "IOSurface",
            "ApplicationServices",
            "Foundation",
            "AVFoundation",
            "AppKit",
            "System",
        ] {
            println!("cargo:rustc-link-lib=framework={framework}");
        }
        if let Some(path) = macos_link_search_path() {
            println!("cargo:rustc-link-lib=clang_rt.osx");
            println!("cargo:rustc-link-search={path}");
        }
        match env::var("PROFILE").unwrap().as_str() {
            "debug" => {
                println!(
                    "cargo:rustc-link-search=\
                     native=crates/libwebrtc-sys/lib/{target}/debug/",
                );
            }
            "release" => {
                println!(
                    "cargo:rustc-link-search=\
                     native=crates/libwebrtc-sys/lib/{target}/release/",
                );
            }
            _ => unreachable!(),
        }
    }
    #[cfg(target_os = "windows")]
    {
        for dep in [
            "Gdi32",
            "Secur32",
            "amstrmid",
            "d3d11",
            "dmoguids",
            "dxgi",
            "msdmo",
            "winmm",
            "wmcodecdspuuid",
        ] {
            println!("cargo:rustc-link-lib=dylib={dep}");
        }
        // TODO: `rustc` always links against non-debug Windows runtime, so we
        //       always use a release build of `libwebrtc`:
        //       https://github.com/rust-lang/rust/issues/39016
        println!(
            "cargo:rustc-link-search=\
             native=crates/libwebrtc-sys/lib/{target}/release/",
        );
    }
    Ok(())
}

#[cfg(target_os = "macos")]
/// Links macOS libraries needed for building.
fn macos_link_search_path() -> Option<String> {
    let output = process::Command::new("clang")
        .arg("--print-search-dirs")
        .output()
        .ok()?;
    if !output.status.success() {
        return None;
    }

    let stdout = String::from_utf8_lossy(&output.stdout);
    stdout
        .lines()
        .filter(|l| l.contains("libraries: ="))
        .find_map(|l| {
            let path = l.split('=').nth(1)?;
            (!path.is_empty()).then(|| format!("{path}/lib/darwin"))
        })
}
