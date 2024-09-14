// swift-tools-version: 6.0

import PackageDescription

let package: Package = .init(
    name: "BarcodeToolsKit",
    platforms: [.iOS(.v15), .tvOS(.v15), .watchOS(.v8), .macOS(.v12), .visionOS(.v1)],
    products: [
        .library(name: "BarcodeToolsKit", targets: ["BarcodeToolsKit"]),
    ],
    targets: [
        .target(name: "BarcodeToolsKit"),
    ],
    swiftLanguageModes: [.v6]
)
