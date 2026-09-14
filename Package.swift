// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "FlexLayout",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(name: "FlexLayout", targets: ["FlexLayout"]),
    ],
    targets: [
        .target(name: "FlexLayout"),
        .testTarget(
            name: "FlexLayoutTests",
            dependencies: ["FlexLayout"]
        ),
    ]
)
