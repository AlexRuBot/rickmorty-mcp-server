// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RickMortyMCP",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.3"),
    ],
    targets: [
        .executableTarget(
            name: "RickMortyMCP",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Logging", package: "swift-log"),
            ],
            path: "Sources/RickMortyMCP"
        ),
        .testTarget(
            name: "RickMortyMCPTests",
            dependencies: [
                .target(name: "RickMortyMCP"),
                .product(name: "XCTVapor", package: "vapor"),
            ],
            path: "Tests/RickMortyMCPTests"
        ),
    ]
)
