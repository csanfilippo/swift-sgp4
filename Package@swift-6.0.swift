// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SGPKit",
    platforms: [.iOS(.v13), .macOS(.v13)],
    products: [
        .library(
            name: "SGPKit",
            targets: ["SGPKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Nimble", .upToNextMajor(from: "10.0.0")),
        .package(url: "https://github.com/Quick/Quick", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "SGPKit",
            dependencies: ["SGPKitOBJC"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
        .target(
            name: "SGPKitCPP",
            path: "Sources/sgp4-147b1ae"
        ),
        .target(
            name: "SGPKitOBJC",
            dependencies: ["SGPKitCPP"],
            path: "Sources/OBJC"),
        .testTarget(
            name: "SGPKitTests",
            dependencies: [
                "SGPKit",
                .product(name: "Nimble", package: "Nimble"),
                .product(name: "Quick", package: "Quick")
            ],
            resources: [
                .copy("Mocks")
            ],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        )
    ],
    cxxLanguageStandard: .cxx17
)
