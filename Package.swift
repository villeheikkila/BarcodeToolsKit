// swift-tools-version: 6.0

import PackageDescription

let package: Package = .init(
    name: "BarcodeGeneratorKit",
    platforms: [.iOS(.v15), .tvOS(.v15), .watchOS(.v8), .macOS(.v12), .visionOS(.v1)],
    products: [
        .library(name: "BarcodeGeneratorKit", targets: ["BarcodeGeneratorKit"]),
    ],
    targets: [
        .target(name: "BarcodeGeneratorKit"),
    ],
    swiftLanguageModes: [.v6]
)
