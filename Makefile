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

RUST_VER ?= 1.55
RUST_NIGHTLY_VER ?= nightly-2021-09-08




###########
# Aliases #
###########

build: cargo.build

deps: flutter.pub

docs: cargo.doc

fmt: cargo.fmt

lint: cargo.lint

run: flutter.run

test: cargo.test




####################
# Flutter commands #
####################

# Build Flutter example application for Windows.
#
# Usage:
#	make flutter.build

flutter.build:
	cd example/ && \
	flutter build windows


# Install Flutter Pub dependencies.
#
# Usage:
#	make flutter.pub [cmd=(get|<pub-cmd>)]

flutter.pub:
	flutter pub $(or $(cmd),get)


# Run Flutter example application for Windows.
#
# Usage:
#	make flutter.run

flutter.run:
	cd example/ && \
	flutter run -d windows --release




##################
# Cargo commands #
##################

# Build `flutter-webrtc-native` crate and copy final artifacts to appropriate
# platform-specific directories.
#
# Usage:
#	make cargo.build [debug=(yes|no)]

lib-out-path = target/$(if $(call eq,$(debug),no),release,debug)

cargo.build:
	cargo build -p flutter-webrtc-native $(if $(call eq,$(debug),no),--release,)
	@mkdir -p windows/rust/include/
	@mkdir -p windows/rust/lib/
	@mkdir -p windows/rust/src/
	@mkdir -p windows/rust/include/flutter-webrtc-native/include/
	cp -f $(lib-out-path)/flutter_webrtc_native.dll \
		windows/rust/lib/flutter_webrtc_native.dll
	cp -f $(lib-out-path)/flutter_webrtc_native.dll.lib \
		windows/rust/lib/flutter_webrtc_native.dll.lib
	cp -f target/cxxbridge/cxxbridge1.lib \
		windows/rust/lib/cxxbridge1.lib
	cp -f target/cxxbridge/flutter-webrtc-native/src/lib.rs.h \
		windows/rust/include/flutter_webrtc_native.h
	cp -f crates/native/include/api.h \
		windows/rust/include/flutter-webrtc-native/include/api.h
	cp -f target/cxxbridge/flutter-webrtc-native/src/lib.rs.cc \
		windows/rust/src/flutter_webrtc_native.cc


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
	cargo +nightly fmt --all $(if $(call eq,$(check),yes),-- --check,)
endif


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




##########################
# Documentation commands #
##########################

docs.rust: cargo.doc




####################
# Testing commands #
####################

test.cargo: cargo.test




##################
# .PHONY section #
##################

.PHONY: build deps docs fmt lint run test \
        cargo.build cargo.doc cargo.fmt cargo.lint cargo.test \
        docs.rust \
        flutter.build flutter.pub flutter.run \
        test.cargo \
