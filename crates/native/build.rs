use std::{env, path::PathBuf};

use anyhow::anyhow;
use cbindgen::Config;

fn main() -> anyhow::Result<()> {
    let crate_dir = env::var("CARGO_MANIFEST_DIR")?;
    let target_dir = {
        let mut out_dir = PathBuf::from(env::var("OUT_DIR")?);
        // Pop to the `CARGO_TARGET_DIR`.
        for _ in 0..4 {
            assert!(out_dir.pop());
        }
        out_dir
            .to_str()
            .ok_or_else(|| anyhow!("Invalid `OUT_DIR` path"))?
            .to_owned()
    };
    let package_name = env::var("CARGO_PKG_NAME")?.replace("-", "_");

    let config = Config {
        namespace: Some(package_name.clone()),
        ..cbindgen::Config::default()
    };

    cbindgen::generate_with_config(&crate_dir, config)?
        .write_to_file(format!("{}/{}.hpp", target_dir, package_name));

    Ok(())
}
