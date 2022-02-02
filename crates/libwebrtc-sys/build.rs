#![warn(clippy::pedantic)]

use std::{
    env, fs, io,
    path::{Path, PathBuf},
};

use anyhow::anyhow;
use dotenv::dotenv;
use walkdir::{DirEntry, WalkDir};

fn main() -> anyhow::Result<()> {
    // This won't override any env vars that already present.
    drop(dotenv());

    download_libwebrtc()?;

    let path = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?);
    let cpp_files = get_cpp_files()?;

    // TODO: `rustc` always links against non-debug Windows runtime, so we
    //       always use a release build of `libwebrtc`:
    //       https://github.com/rust-lang/rust/issues/39016
    println!(
        "cargo:rustc-link-search=native=crates/libwebrtc-sys/lib/release/"
    );
    println!("cargo:rustc-link-lib=webrtc");

    println!("cargo:rustc-link-lib=dylib=dmoguids");
    println!("cargo:rustc-link-lib=dylib=wmcodecdspuuid");
    println!("cargo:rustc-link-lib=dylib=amstrmid");
    println!("cargo:rustc-link-lib=dylib=msdmo");
    println!("cargo:rustc-link-lib=dylib=winmm");
    println!("cargo:rustc-link-lib=dylib=Secur32");

    cxx_build::bridge("src/bridge.rs")
        .files(&cpp_files)
        .include(path.join("include"))
        .include(path.join("lib/include"))
        .include(path.join("lib/include/third_party/abseil-cpp"))
        .include(path.join("lib/include/third_party/libyuv/include"))
        .flag("-DWEBRTC_WIN")
        .flag("-DNOMINMAX")
        .flag("/std:c++17")
        .compile("libwebrtc-sys");

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
    let mut libwebrtc_url = env::var("LIBWEBRTC_URL")?;
    libwebrtc_url.push_str("/libwebrtc-win-x64.tar.gz");

    let manifest_path = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?);
    let temp_dir = manifest_path.join("temp");
    let archive = temp_dir.join("libwebrtc-win-x64.tar.gz");
    let lib_dir = manifest_path.join("lib");

    // Force download if `INSTALL_WEBRTC=1`.
    if env::var("INSTALL_WEBRTC").as_deref().unwrap_or("0") == "0" {
        // Skip download if already downloaded.
        if fs::read_dir(&lib_dir)?.fold(0, |acc, b| {
            if b.unwrap().file_name().to_string_lossy().starts_with('.') {
                acc
            } else {
                acc + 1
            }
        }) != 0
        {
            return Ok(());
        }
    }

    // Clear `temp` directory.
    if temp_dir.exists() {
        fs::remove_dir_all(&temp_dir)?;
    }
    fs::create_dir_all(&temp_dir)?;

    // Download compiled `libwebrtc` archive.
    {
        let mut resp = reqwest::blocking::get(&libwebrtc_url)?;
        let mut out_file = fs::File::create(&archive)?;
        io::copy(&mut resp, &mut out_file)?;
    }

    // Clear `lib` directory.
    for entry in fs::read_dir(&lib_dir)? {
        let entry = entry?;
        if !entry.file_name().to_string_lossy().starts_with('.') {
            if entry.metadata()?.is_dir() {
                fs::remove_dir_all(entry.path())?;
            } else {
                fs::remove_file(entry.path())?;
            }
        }
    }

    // Untar the downloaded archive.
    std::process::Command::new("tar")
        .args(&[
            "-xf",
            archive
                .to_str()
                .ok_or_else(|| anyhow!("Invalid archive path"))?,
            "-C",
            lib_dir
                .to_str()
                .ok_or_else(|| anyhow!("Invalid `lib/` dir path"))?,
        ])
        .status()?;

    fs::remove_dir_all(&temp_dir)?;

    Ok(())
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
