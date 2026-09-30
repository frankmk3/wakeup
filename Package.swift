// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "WakeUp",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "WakeUp",
            path: "Sources/WakeUp"
        )
    ]
)
