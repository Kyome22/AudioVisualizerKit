// swift-tools-version: 5.10
import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableExperimentalFeature("StrictConcurrency"),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("GlobalConcurrency")
]

let package = Package(
    name: "AudioVisualizerKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "AudioVisualizerKit",
            targets: ["AudioVisualizerKit"]
        ),
    ],
    targets: [
        .target(
            name: "AudioVisualizerKit",
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "AudioVisualizerKitTests",
            dependencies: ["AudioVisualizerKit"],
            swiftSettings: swiftSettings
        ),
    ]
)
