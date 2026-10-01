// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DeclarativeAppKit",
    platforms: [.macOS(.v11)],
    products: [
        .library(name: "DeclarativeAppKit", targets: ["DeclarativeAppKit"])
    ],
    dependencies: [],
    targets: [
        .target(name: "DeclarativeAppKit"),
        .testTarget(name: "DeclarativeAppKitTests", dependencies: ["DeclarativeAppKit"])
    ],
    swiftLanguageVersions: [.v5]
)
