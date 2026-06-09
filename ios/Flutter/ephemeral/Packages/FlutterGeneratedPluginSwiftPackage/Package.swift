// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// Generated file. Do not edit.
//

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [
        .package(name: "url_launcher_ios", path: "../.packages/url_launcher_ios-6.4.1"),
        .package(name: "shared_preferences_foundation", path: "../.packages/shared_preferences_foundation-2.5.6"),
        .package(name: "record_ios", path: "../.packages/record_ios-2.0.0"),
        .package(name: "purchases_ui_flutter", path: "../.packages/purchases_ui_flutter-10.2.2"),
        .package(name: "purchases_flutter", path: "../.packages/purchases_flutter-10.2.2"),
        .package(name: "just_audio", path: "../.packages/just_audio-0.9.46"),
        .package(name: "audio_session", path: "../.packages/audio_session-0.1.25"),
        .package(name: "google_sign_in_ios", path: "../.packages/google_sign_in_ios-5.9.0"),
        .package(name: "sqlite3_flutter_libs", path: "../.packages/sqlite3_flutter_libs-0.5.42"),
        .package(name: "FlutterFramework", path: "../.packages/FlutterFramework")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "url-launcher-ios", package: "url_launcher_ios"),
                .product(name: "shared-preferences-foundation", package: "shared_preferences_foundation"),
                .product(name: "record-ios", package: "record_ios"),
                .product(name: "purchases-ui-flutter", package: "purchases_ui_flutter"),
                .product(name: "purchases-flutter", package: "purchases_flutter"),
                .product(name: "just-audio", package: "just_audio"),
                .product(name: "audio-session", package: "audio_session"),
                .product(name: "google-sign-in-ios", package: "google_sign_in_ios"),
                .product(name: "sqlite3-flutter-libs", package: "sqlite3_flutter_libs"),
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
