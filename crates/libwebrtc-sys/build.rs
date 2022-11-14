#![warn(clippy::pedantic)]

#[cfg(not(target_os = "windows"))]
use std::ffi::OsString;
#[cfg(target_os = "macos")]
use std::process;
use std::{
    env, fs,
    fs::File,
    io::{BufReader, BufWriter, Read, Write},
    path::{Path, PathBuf},
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
                                                    /106.0.5249.91";

fn main() -> anyhow::Result<()> {
    download_libwebrtc()?;

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
        build.flag("-DWEBRTC_WIN").flag("/std:c++17");
    }

    #[cfg(feature = "fake_media")]
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
    println!("cargo:rerun-if-env-changed=LIBWEBRTC_URL");

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
            "0e953fae2c854c147970b2fcca78c45c456f618df7b35a56ea88cec7bdb7400f"
        }
        "x86_64-unknown-linux-gnu" => {
            "38077e57322ed5f0934f8e960eae7769dfbe5619f345b559cc7bca5e32c912ed"
        }
        "aarch64-apple-darwin" => {
            "a6fc75d433b10ec2a646064cbbcc6c1f5d0783fb342dad144521bb8dc7bcd886"
        }
        "x86_64-apple-darwin" => {
            "433db8207ed8343bdf751505597213c3267b8ef52287a49466ce7bb7df145e0c"
        }
        "x86_64-pc-windows-msvc" => {
            "51665201452ff7ec59aa73c59f2c532f8e977a8fa936f093c343a631f3986a96"
        }
        arch => return Err(anyhow::anyhow!("Unsupported target: {arch}")),
    })
}

/// Returns [`PathBuf`] to the directory containing the library.
fn libpath() -> anyhow::Result<PathBuf> {
    let target = get_target()?;
    let manifest_path = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?);
    Ok(manifest_path.join("lib").join(&target))
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
        if fs::metadata(&lib_dir)
            .map(|m| m.is_dir())
            .unwrap_or_default()
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
        let mut resp = BufReader::new(reqwest::blocking::get(&format!(
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
            let _ = out_file.write(&buffer[0..count])?;
        }

        if format!("{:x}", hasher.finalize()) != expected_hash {
            bail!("SHA-256 checksum doesn't match");
        }
    }

    // Clean up `lib` directory.
    if lib_dir.exists() {
        fs::remove_dir_all(&lib_dir)?;
    }
    fs::create_dir_all(&lib_dir)?;

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

    #[allow(unused_mut)]
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
