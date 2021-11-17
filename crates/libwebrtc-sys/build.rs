use std::{env, fs, io, path::PathBuf};

use anyhow::anyhow;
use dotenv::dotenv;

fn main() -> anyhow::Result<()> {
    // This won't override any env vars that already present.
    let _ = dotenv();

    download_libwebrtc()?;

    let path = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?);

    // TODO: `rustc` always links against non-debug Windows runtime, so we
    //       always use a release build of `libwebrtc`:
    //       https://github.com/rust-lang/rust/issues/39016
    println!(
        "cargo:rustc-link-search=native=crates/libwebrtc-sys/lib/release/"
    );
    println!("cargo:rustc-link-lib=webrtc");
    println!("cargo:rustc-link-lib=dylib=winmm");
    println!("cargo:rustc-link-lib=dylib=secur32");
    println!("cargo:rustc-link-lib=dylib=dmoguids");
    println!("cargo:rustc-link-lib=dylib=wmcodecdspuuid");
    println!("cargo:rustc-link-lib=dylib=amstrmid");
    println!("cargo:rustc-link-lib=dylib=msdmo");
    println!("cargo:rustc-link-lib=dylib=gdi32");
    println!("cargo:rustc-link-lib=dylib=d3d11");
    println!("cargo:rustc-link-lib=dylib=dxgi");

    cxx_build::bridge("src/bridge.rs")
        .file("src/bridge.cc")
        .include(path.join("lib/include"))
        .include(path.join("lib/include/third_party/abseil-cpp"))
        .define("WEBRTC_WIN", "1")
        .define("NOMINMAX", "1")
        .define("WEBRTC_USE_BUILTIN_ISAC_FLOAT", "1")
        .compile("libwebrtc-sys");

    println!("cargo:rerun-if-changed=src/bridge.cc");
    println!("cargo:rerun-if-changed=src/bridge.rs");
    println!("cargo:rerun-if-changed=include/bridge.h");
    println!("cargo:rerun-if-changed=./lib");

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
