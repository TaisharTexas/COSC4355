// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "VaporAPI",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),
    ],
    targets: [
        .executableTarget(
            name: "VaporAPI",
            dependencies: [
                .product(name: "Vapor", package: "vapor")
            ]
        ),
    ]
)
