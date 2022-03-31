#![warn(clippy::pedantic)]

fn main() {
    cxx_build::bridge("src/cpp_api.rs").compile("cpp_api_bindings");
}
