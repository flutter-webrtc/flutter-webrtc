// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "flutter_webrtc",
    platforms: [
        .macOS("10.15")
    ],
    products: [
        .library(name: "flutter-webrtc", targets: ["flutter_webrtc"]),
        // Lets dependent plugins (e.g. livekit_client) import WebRTC without
        // declaring a second copy of the binary target.
        .library(name: "WebRTC", targets: ["WebRTC"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .binaryTarget(
            name: "WebRTC",
            url: "https://github.com/webrtc-sdk/Specs/releases/download/150.7871.01/WebRTC.xcframework.zip",
            checksum: "03815cdf2f6a0ed328c94d74cce8fd1b8d2b6e95e2b37eab66795012fcecfdfa"
        ),
        .target(
            name: "flutter_webrtc",
            dependencies: [
                "WebRTC",
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            cSettings: [
                .headerSearchPath("include/flutter_webrtc")
            ],
            linkerSettings: [
                // Ends up weak-linked (LC_LOAD_WEAK_DYLIB) like the podspec's weak_frameworks:
                // all ScreenCaptureKit usage is @available-guarded and the 10.15 platform
                // minimum above predates the framework, so clang weak-imports its symbols
                // and no explicit weak_framework flag is needed. This holds as long as
                // ScreenCaptureKit APIs are only used behind availability checks.
                .linkedFramework("ScreenCaptureKit")
            ]
        )
    ]
)
