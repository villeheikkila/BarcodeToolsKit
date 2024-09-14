// swift-tools-version: 6.0

import PackageDescription

let package: Package = .init(
    name: "BarcodeToolsKit",
    platforms: [.iOS(.v17), .tvOS(.v17), .watchOS(.v9), .macOS(.v14), .visionOS(.v1)],
    products: [
        .library(name: "BarcodeToolsKit", targets: ["BarcodeToolsKit"]),
    ],
    targets: [
        .target(name: "BarcodeToolsKit"),
    ],
    swiftLanguageModes: [.v6]
)
