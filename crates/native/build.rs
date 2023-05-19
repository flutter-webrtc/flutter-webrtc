#![warn(clippy::pedantic)]

#[cfg(target_os = "macos")]
use std::{env, path::PathBuf, process};

#[allow(clippy::unnecessary_wraps)]
fn main() -> anyhow::Result<()> {
    #[cfg(target_os = "macos")]
    {
        println!("cargo:rustc-env=MACOSX_DEPLOYMENT_TARGET=10.11");
        println!("cargo:rustc-link-arg=-Wl,-undefined,dynamic_lookup");
        println!(
            "cargo:rustc-link-arg=-Wl,-install_name,\
             @rpath/libmedea_flutter_webrtc_native.dylib"
        );

        let path = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?);

        link_libs();

        let mut build = cc::Build::new();
        build
            .file("src/media_devices.m")
            .include(path.join("include"))
            .flag("-DNOMINMAX")
            .flag("-objC")
            .flag("-fobjc-arc");
        build.compile("medea-flutter-webrtc-native");
    }

    #[cfg(not(target_os = "macos"))]
    cxx_build::bridge("src/renderer.rs")
        .flag("-std=c++17")
        .compile("cpp_api_bindings");

    Ok(())
}

#[cfg(target_os = "macos")]
/// Emits all the required `rustc-link-lib` instructions.
fn link_libs() {
    println!("cargo:rustc-link-lib=framework=AVFoundation");
    if let Some(path) = macos_link_search_path() {
        println!("cargo:rustc-link-lib=clang_rt.osx");
        println!("cargo:rustc-link-search={path}");
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
        _ => unreachable!(),
    }
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
