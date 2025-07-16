###############################
# Common defaults/definitions #
###############################

comma := ,

# Checks two given strings for equality.
eq = $(if $(or $(1),$(2)),$(and $(findstring $(1),$(2)),\
                                $(findstring $(2),$(1))),1)




######################
# Project parameters #
######################

RUST_VER ?= 1.85
RUST_NIGHTLY_VER ?= nightly-2025-02-22

FLUTTER_RUST_BRIDGE_VER ?= $(strip \
	$(shell grep -A1 'name = "flutter_rust_bridge"' Cargo.lock \
	        | grep -v 'flutter_rust_bridge' \
	        | cut -d'"' -f2))

KTFMT_VER ?= 0.33

CURRENT_OS ?= $(strip $(or $(os),\
	$(if $(call eq,$(OS),Windows_NT),windows,\
	$(if $(call eq,$(shell uname -s),Darwin),macos,linux))))

LINUX_TARGETS := x86_64-unknown-linux-gnu
MACOS_TARGETS := x86_64-apple-darwin \
                 aarch64-apple-darwin
WINDOWS_TARGETS := x86_64-pc-windows-msvc




###########
# Aliases #
###########

build: cargo.build

clean: cargo.clean flutter.clean

codegen: cargo.gen

deps: flutter.pub

docs: cargo.doc

fmt: cargo.fmt flutter.fmt kt.fmt swift.fmt

lint: cargo.lint flutter.analyze

run: flutter.run

test: cargo.test flutter.test.desktop flutter.test.mobile




####################
# Flutter commands #
####################

# Lint Flutter Dart sources with dartanalyzer.
#
# Usage:
#	make flutter.analyze

flutter.analyze:
ifeq ($(wildcard .packages),)
	flutter pub get
endif
	flutter analyze


# Clean built Flutter artifacts and cache.
#
# Usage:
#	make flutter.clean

flutter.clean:
	flutter clean


# Build Flutter example application for Windows.
#
# Usage:
#	make flutter.build [platform=(apk|linux|macos|windows)]

flutter.build:
	cd example/ && \
	flutter build $(platform)


# Format Flutter Dart sources with dartfmt.
#
# Usage:
#	make flutter.fmt [check=(no|yes)]

flutter.fmt:
ifeq ($(wildcard .dart_tool),)
	flutter pub get
endif
	dart format $(if $(call eq,$(check),yes), --set-exit-if-changed,) .
	flutter pub run import_sorter:main --no-comments \
		$(if $(call eq,$(check),yes),--exit-if-changed,)


# Install Flutter Pub dependencies.
#
# Usage:
#	make flutter.pub [cmd=(get|<pub-cmd>)]

flutter.pub:
	flutter pub $(or $(cmd),get)


# Run Flutter example application for the current OS.
#
# Usage:
#	make flutter.run [debug=(yes|no)] [device=<device-id>]

flutter.run:
	cd example/ && \
	flutter run $(if $(call eq,$(debug),no),--release,) \
		$(if $(call eq,$(device),),,-d $(device))


# Run Flutter plugin integration tests on the current host as desktop.
#
# Usage:
#	make flutter.test.desktop

flutter.test.desktop:
	cd example/ && \
	flutter test integration_test -d $(CURRENT_OS)


# Run Flutter plugin integration tests on an attached mobile device.
#
# Usage:
#	make flutter.test.mobile [device=<device-id>] [debug=(no|yes)]

flutter.test.mobile:
	cd example/ && \
	flutter drive --driver=test_driver/integration_driver.dart \
	              --target=integration_test/webrtc_test.dart \
	              $(if $(call eq,$(debug),yes),--debug,--profile) \
	              $(if $(call eq,$(device),),,-d $(device))




##################
# Cargo commands #
##################

# Clean built Rust artifacts.
#
# Usage:
#	make cargo.clean

cargo.clean:
	cargo clean


# Build `medea-flutter-webrtc-native` crate and copy final artifacts to
# appropriate platform-specific directories.
#
# Usage:
#	make cargo.build [debug=(yes|no)]
#		[( [platform=all]
#		 | platform=linux [targets=($(LINUX_TARGETS)|<t1>[,<t2>...])]
#		 | platform=macos [targets=($(MACOS_TARGETS)|<t1>[,<t2>...])]
#		 | platform=windows [targets=($(WINDOWS_TARGETS)|<t1>[,<t2>...])] )]

cargo-build-targets-linux = $(strip \
	$(subst $(comma), ,$(or $(targets),$(LINUX_TARGETS))))
cargo-build-targets-macos = $(strip \
	$(subst $(comma), ,$(or $(targets),$(MACOS_TARGETS))))
cargo-build-targets-windows = $(strip \
	$(subst $(comma), ,$(or $(targets),$(WINDOWS_TARGETS))))

cargo.build:
ifeq ($(platform),all)
	@make cargo.build platform=linux
	@make cargo.build platform=macos
	@make cargo.build platform=windows
endif
ifeq ($(platform),linux)
	@mkdir -p linux/rust/include/medea-flutter-webrtc-native/include/
	@mkdir -p linux/rust/src/
	$(foreach t,$(cargo-build-targets-linux),\
		$(call cargo.build.target,$(t)))
	$(foreach t,$(cargo-build-targets-linux),\
		mkdir -p linux/rust/lib/$(t)/)
	$(foreach t,$(cargo-build-targets-linux),\
		cp -f target/$(t)/$(if $(call eq,$(debug),no),release,debug)/libmedea_flutter_webrtc_native.so \
			linux/rust/lib/$(target)/libmedea_flutter_webrtc_native.so)
	cp -f target/$(word 1,$(cargo-build-targets-linux))/cxxbridge/medea-flutter-webrtc-native/src/renderer.rs.h \
		linux/rust/include/medea_flutter_webrtc_native.h
	cp -f target/$(word 1,$(cargo-build-targets-linux))/cxxbridge/medea-flutter-webrtc-native/src/renderer.rs.cc \
		linux/rust/src/medea_flutter_webrtc_native.cc
	cp -f crates/native/include/api.h \
		linux/rust/include/medea-flutter-webrtc-native/include/api.h
endif
ifeq ($(platform),macos)
	$(foreach t,$(cargo-build-targets-macos),\
		$(call cargo.build.target,$(t)))
	@mkdir -p macos/rust/lib/
	lipo -create $(foreach t,$(cargo-build-targets-macos),\
	             target/$(t)/$(if $(call eq,$(debug),no),release,debug)/libmedea_flutter_webrtc_native.dylib) \
	     -output macos/rust/lib/libmedea_flutter_webrtc_native.dylib
endif
ifeq ($(platform),windows)
	@mkdir -p windows/rust/include/
	@mkdir -p windows/rust/src/
	@mkdir -p windows/rust/include/medea-flutter-webrtc-native/include/
	$(foreach t,$(cargo-build-targets-windows),\
		$(call cargo.build.target,$(t)))
	$(foreach t,$(cargo-build-targets-windows),\
		mkdir -p windows/rust/lib/$(t)/)
	$(foreach t,$(cargo-build-targets-windows),\
		cp -f target/$(t)/$(if $(call eq,$(debug),no),release,debug)/medea_flutter_webrtc_native.dll \
			windows/rust/lib/$(target)/medea_flutter_webrtc_native.dll)
	$(foreach t,$(cargo-build-targets-windows),\
        cp -f target/$(t)/$(if $(call eq,$(debug),no),release,debug)/medea_flutter_webrtc_native.dll.lib \
			windows/rust/lib/$(target)/medea_flutter_webrtc_native.dll.lib)
	cp -f target/$(word 1,$(cargo-build-targets-windows))/cxxbridge/medea-flutter-webrtc-native/src/renderer.rs.h \
		windows/rust/include/medea_flutter_webrtc_native.h
	cp -f target/$(word 1,$(cargo-build-targets-windows))/cxxbridge/medea-flutter-webrtc-native/src/renderer.rs.cc \
		windows/rust/src/medea_flutter_webrtc_native.cc
	cp -f crates/native/include/api.h \
		windows/rust/include/medea-flutter-webrtc-native/include/api.h
endif
define cargo.build.target
	$(eval target := $(strip $(1)))
	cargo build -p medea-flutter-webrtc-native --target $(target) \
		$(if $(call eq,$(debug),no),--release,)
endef


# Generate documentation for project crates.
#
# Usage:
#	make cargo.doc [open=(yes|no)] [clean=(no|yes)] [dev=(no|yes)]

cargo.doc:
ifeq ($(clean),yes)
	@rm -rf target/doc/
endif
	cargo doc --workspace --no-deps \
		$(if $(call eq,$(dev),yes),--document-private-items,) \
		$(if $(call eq,$(open),no),,--open)


# Format Rust sources with rustfmt.
#
# Usage:
#	make cargo.fmt [check=(no|yes)] [dockerized=(no|yes)]

cargo.fmt:
ifeq ($(dockerized),yes)
	docker run --rm --network=host -v "$(PWD)":/app -w /app \
		-u $(shell id -u):$(shell id -g) \
		-v "$(HOME)/.cargo/registry":/usr/local/cargo/registry \
		ghcr.io/instrumentisto/rust:$(RUST_NIGHTLY_VER) \
			make cargo.fmt check=$(check) dockerized=no
else
	cargo +nightly fmt --all $(if $(call eq,$(check),yes),--check,)
endif


# Generates Rust and Dart side interop bridge.
#
# Usage:
#	make cargo.gen

cargo.gen:
ifeq ($(shell which flutter_rust_bridge_codegen),)
	cargo install flutter_rust_bridge_codegen --locked \
	                                          --vers=$(FLUTTER_RUST_BRIDGE_VER)
else
ifneq ($(strip $(shell flutter_rust_bridge_codegen --version | cut -d ' ' -f2)),$(FLUTTER_RUST_BRIDGE_VER))
	cargo install flutter_rust_bridge_codegen --locked --force \
	                                          --vers=$(FLUTTER_RUST_BRIDGE_VER)
endif
endif
ifeq ($(shell which cbindgen),)
	cargo install cbindgen
endif
ifeq ($(CURRENT_OS),macos)
ifeq ($(shell brew list | grep -Fx llvm),)
	brew install llvm
endif
endif
	flutter_rust_bridge_codegen generate \
		--rust-input=crate::api \
		--rust-root=crates/native \
		--no-add-mod-to-lib \
		--dart-output=lib/src/api/bridge \
		--no-web
	dart run build_runner build --delete-conflicting-outputs


# Lint Rust sources with Clippy.
#
# Usage:
#	make cargo.lint [dockerized=(no|yes)]

cargo.lint:
ifeq ($(dockerized),yes)
	docker run --rm --network=host -v "$(PWD)":/app -w /app \
		-u $(shell id -u):$(shell id -g) \
		-v "$(HOME)/.cargo/registry":/usr/local/cargo/registry \
		ghcr.io/instrumentisto/rust:$(RUST_VER) \
			make cargo.lint dockerized=no
else
	cargo clippy --workspace -- -D warnings
endif


# Run Rust tests of project.
#
# Usage:
#	make cargo.test

cargo.test:
	cargo test --workspace


# Install or upgrade all the required project's targets for Rust.
#
# Usage:
#	make rustup.targets [only=(linux|macos|windows)]

rustup-targets = $(MACOS_TARGETS) \
                 $(LINUX_TARGETS) \
                 $(WINDOWS_TARGETS)
ifeq ($(only),linux)
rustup-targets = $(LINUX_TARGETS)
endif
ifeq ($(only),macos)
rustup-targets = $(MACOS_TARGETS)
endif
ifeq ($(only),windows)
rustup-targets = $(WINDOWS_TARGETS)
endif

rustup.targets:
	rustup target add $(rustup-targets)




##################
# Kotin commands #
##################

# Format Kotlin sources with ktfmt.
#
# Usage:
#	make kt.fmt [check=(no|yes)]

kt-fmt-bin = .cache/ktfmt-$(KTFMT_VER).jar

kt.fmt:
ifeq ($(wildcard $(kt-fmt-bin)),)
	@mkdir -p $(dir $(kt-fmt-bin))
	curl -fL -o $(kt-fmt-bin) \
	     https://search.maven.org/remotecontent?filepath=com/facebook/ktfmt/$(KTFMT_VER)/ktfmt-$(KTFMT_VER)-jar-with-dependencies.jar
endif
	java -jar $(kt-fmt-bin) \
	     $(if $(call eq,$(check),yes),--set-exit-if-changed,) \
		android/src/main/kotlin/




##################
# Swift commands #
##################

# Format Swift sources with SwiftFormat.
#
# Usage:
#	make swift.fmt [check=(no|yes)] [dockerized=(no|yes)]

swift.fmt:
ifeq ($(dockerized),yes)
	docker run --rm -v "$(PWD)":/app -w /app \
		-u $(shell id -u):$(shell id -g) \
		ghcr.io/nicklockwood/swiftformat:latest \
			$(if $(call eq,$(check),yes),--lint,) ios/Classes/
else
ifeq ($(shell which swiftformat),)
ifeq ($(CURRENT_OS),macos)
	brew install swiftformat
endif
endif
	swiftformat $(if $(call eq,$(check),yes),--lint,) ios/Classes/
endif




##########################
# Documentation commands #
##########################

docs.rust: cargo.doc




####################
# Testing commands #
####################

test.cargo: cargo.test

test.flutter: flutter.test.desktop flutter.test.mobile




##################
# .PHONY section #
##################

.PHONY: build clean codegen deps docs fmt lint run test \
        cargo.clean cargo.build cargo.doc cargo.fmt cargo.gen cargo.lint \
        	cargo.test \
        docs.rust \
        flutter.analyze flutter.clean flutter.build flutter.fmt flutter.pub \
        	flutter.run flutter.test.desktop flutter.test.mobile \
        kt.fmt \
        rustup.targets \
        swift.fmt \
        test.cargo test.flutter
