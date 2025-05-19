Contribution Guide
==================

We love contributions from everyone, whether it's raising an issue, reporting a bug, adding a feature, or helping improve documentation. Maintaining the `medea_flutter_webrtc` plugin for all the platforms is not an easy task, so everything you do is support for the project.

1. [Code style](#code-style)
    - [Rust](#rust)
    - [Dart](#dart)
    - [Kotlin](#kotlin)
    - [Swift](#swift)




## Code style


### Rust

**All [Rust] source code must be formatted with [rustfmt] and linted with [Clippy] linter** (see `cargo.fmt` and `cargo.lint` commands in [`Makefile`]), customized by project settings ([`.rustfmt.toml`](.rustfmt.toml) and [`.clippy.toml`](.clippy.toml) files).

Additional rules, not handled by [rustfmt] and [Clippy] are described below.

#### Attributes

**Attributes** on declarations must be **sorted in alphabetic order**. **Items inside attribute** must be **sorted in alphabetic order** too (in the same manner they're sorted by [rustfmt] inside `use` statement).

##### 👍 Correct example

```rust
#[allow(clippy::mut_mut)]
#[derive(Debug, Deserialize, Serialize, smart_default::SmartDefault)]
#[serde(deny_unknown_fields)]
struct User {
    #[serde(default)]
    id: u64,
}
```

##### 🚫 Wrong examples

```rust
#[serde(deny_unknown_fields)]
#[derive(Debug, Deserialize, Serialize, smart_default::SmartDefault)]
#[allow(clippy::mut_mut)]
struct User {
    id: u64,
}
```

```rust
#[derive(Debug, smart_default::SmartDefault, Serialize, Deserialize)]
struct User {
    id: u64,
}
```

```rust
#[derive(smart_default::SmartDefault, Debug, Deserialize, Serialize)]
struct User {
    id: u64,
}
```

#### Markdown in docs

It's **recommended to use H1 headers** (`# Header`) in [Rust] docs as this way is widely adopted in [Rust] community. **Blank lines** before headers must be **reduced to a single one**.

**Bold** and _italic_ text should be marked via `**` and `_` accordingly.

Other **code definitions** should be **referred via ```[`Entity`]``` marking** ([intra-doc links][1]).

##### 👍 Correct example

```rust
/// Type of [`User`]'s unique identifier.
///
/// # Constraints
///
/// - It **must not be zero**.
/// - It _should not_ overflow [`i64::max_value`] due to usage in database.
struct UserId(u64);
```

##### 🚫 Wrong examples

- H2 header is used at the topmost level:

    ```rust
    /// Type of [`User`]'s unique identifier.
    ///
    /// ## Constraints
    ///
    /// - It **must not be zero**.
    /// - It _should not_ overflow [`i64::max_value`] due to usage in database.
    struct UserId(u64);
    ```

- Code definition is not referred correctly:

    ```rust
    /// Type of User's unique identifier.
    ///
    /// # Constraints
    ///
    /// - It **must not be zero**.
    /// - It _should not_ overflow `i64::max_value` due to usage in database.
    struct UserId(u64);
    ```

- Incorrect bold/italic marking:

    ```rust
    /// Type of [`User`]'s unique identifier.
    ///
    /// # Constraints
    ///
    /// - It __must not be zero__.
    /// - It *should not* overflow [`i64::max_value`] due to usage in database.
    struct UserId(u64);
    ```


### Dart

**All [Dart] source code must be formatted with [dartfmt]** (see `flutter.fmt` command in [`Makefile`]).


### Kotlin

**All [Kotlin] source code must be formatted with [ktfmt]** (see `kt.fmt` command in [`Makefile`]).


### Swift

**All [Swift] source code must be formatted with [swiftformat]** (see `swift.fmt` command in [`Makefile`]), customized by project settings ([`.swiftformat`](.swiftformat) file).




[`Makefile`]: Makefile
[Clippy]: https://github.com/rust-lang/rust-clippy
[Dart]: https://dart.dev
[dartfmt]: https://dart.dev/tools/dart-format
[Kotlin]: https://kotlinlang.org
[ktfmt]: https://github.com/facebook/ktfmt
[Rust]: https://www.rust-lang.org
[rustfmt]: https://github.com/rust-lang/rustfmt
[Swift]: https://www.apple.com/swift
[swiftformat]: https://github.com/nicklockwood/SwiftFormat

[1]: https://doc.rust-lang.org/rustdoc/write-documentation/linking-to-items-by-name.html
