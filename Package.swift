// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "GPTBot",
    platforms: [.macOS(.v10_15)],
    products: [
        .executable(name: "gptbot", targets: ["gptbot"])
    ],
    dependencies: [
        .package(url: "https://github.com/ErikaFoxelot/GPTEncoder.git", branch: "main"),
        .package(url: "https://github.com/MacPaw/OpenAI.git", from: "0.2.4"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.3"),
    ],
    targets: [
        .executableTarget(
            name: "gptbot",
            dependencies: [
                "GPTEncoder",
                "OpenAI",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        )
    ]
)
