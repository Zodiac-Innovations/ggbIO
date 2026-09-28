// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ggbIO",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [
        .library(name: "GGBIO", targets: ["GGBIO"]),
        .library(name: "GGBIOApple", targets: ["GGBIOApple"])
    ],
    targets: [
        .target(name: "GGBIO"),
        .target(name: "GGBIOApple", dependencies: ["GGBIO"])
    ],
    swiftLanguageModes: [.v6]
)
