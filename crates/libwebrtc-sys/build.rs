#![warn(clippy::pedantic)]

#[cfg(not(target_os = "windows"))]
use std::ffi::OsString;
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
                                                    /101.0.4951.64";

#[cfg(all(target_os = "linux", target_arch = "aarch64"))]
static SHA256SUM: &str =
    "80301279c2435b3e33c5f610bb7785c37939c146965932755c0a4f693afad3a9";
#[cfg(all(target_os = "linux", target_arch = "x86_64"))]
static SHA256SUM: &str =
    "b78fdc44d7fabdb270aefa3007f22e4fd535521bb3e77227d33053f17c6157e3";
#[cfg(all(target_os = "macos", target_arch = "aarch64"))]
static SHA256SUM: &str =
    "37eb55ed34bc6492d01806945b82f25c81404b5e122a8dca9e416640ece0cf51";
#[cfg(all(target_os = "macos", target_arch = "x86_64"))]
static SHA256SUM: &str =
    "fc15c33464ea4f1515db0fb4d67ca46bfb69ec339339ef891be9c3f347ede326";
#[cfg(all(target_os = "windows", target_arch = "x86_64"))]
static SHA256SUM: &str =
    "7c75df843059ebf1a264f5a5693875b38fd1dcf88ea8bff3b36902f0306b6587";

fn main() -> anyhow::Result<()> {
    download_libwebrtc()?;

    let path = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?);
    let cpp_files = get_cpp_files()?;

    println!("cargo:rustc-link-lib=webrtc");

    link_libs();

    let mut build = cxx_build::bridge("src/bridge.rs");
    build
        .files(&cpp_files)
        .include(path.join("include"))
        .include(path.join("lib/include"))
        .include(path.join("lib/include/third_party/abseil-cpp"))
        .include(path.join("lib/include/third_party/libyuv/include"));

    #[cfg(target_os = "windows")]
    build.flag("-DNDEBUG");
    #[cfg(not(target_os = "windows"))]
    if env::var_os("PROFILE") == Some(OsString::from("release")) {
        build.flag("-DNDEBUG");
    }

    #[cfg(target_os = "windows")]
    {
        build
            .flag("-DWEBRTC_WIN")
            .flag("-DNOMINMAX")
            .flag("/std:c++17");
    }
    #[cfg(target_os = "linux")]
    {
        build
            .flag("-DWEBRTC_LINUX")
            .flag("-DWEBRTC_POSIX")
            .flag("-DNOMINMAX")
            .flag("-DWEBRTC_USE_X11")
            .flag("-std=c++17");
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

/// Downloads and unpacks compiled `libwebrtc` library.
fn download_libwebrtc() -> anyhow::Result<()> {
    let manifest_path = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?);
    let temp_dir = manifest_path.join("temp");
    let lib_dir = manifest_path.join("lib");

    let tar_file = {
        let mut name = String::from("libwebrtc-");

        #[cfg(target_os = "windows")]
        name.push_str("windows-");
        #[cfg(target_os = "linux")]
        name.push_str("linux-");
        #[cfg(target_os = "macos")]
        name.push_str("macos-");

        #[cfg(target_arch = "aarch64")]
        name.push_str("arm64.tar.gz");
        #[cfg(target_arch = "x86_64")]
        name.push_str("x64.tar.gz");

        name
    };
    let archive = temp_dir.join(&tar_file);
    let checksum = lib_dir.join("CHECKSUM");

    // Force download if `INSTALL_WEBRTC=1`.
    if env::var("INSTALL_WEBRTC").as_deref().unwrap_or("0") == "0" {
        // Skip download if already downloaded and checksum matches.
        if fs::metadata(&lib_dir)
            .map(|m| m.is_dir())
            .unwrap_or_default()
            && fs::read(&checksum).unwrap_or_default().as_slice()
                == SHA256SUM.as_bytes()
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

        if format!("{:x}", hasher.finalize()) != SHA256SUM {
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
    fs::write(&checksum, SHA256SUM).map_err(Into::into)
}

/// Returns a list of all C++ sources that should be compiled.
fn get_cpp_files() -> anyhow::Result<Vec<PathBuf>> {
    let dir = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?)
        .join("src")
        .join("cpp");

    Ok(get_files_from_dir(dir))
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
fn link_libs() {
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
            "cargo:rustc-link-search=native=crates/libwebrtc-sys/lib/release/",
        );
    }
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
                     native=crates/libwebrtc-sys/lib/debug/",
                );
            }
            "release" => {
                println!(
                    "cargo:rustc-link-search=\
                     native=crates/libwebrtc-sys/lib/release/",
                );
            }
            _ => (),
        }
    }
}
