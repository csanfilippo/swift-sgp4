// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "SGPKit",
	platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "SGPKit",
            targets: ["SGPKit"]),
    ],
    dependencies: [

    ],
    targets: [
        .target(
            name: "SGPKit",
            dependencies: ["SGPKitOBJC"]),
		.target(
			name: "SGPKitCPP",
			path: "Sources/sgp4-f5cb54b"
		),
		.target(
			name: "SGPKitOBJC",
			dependencies: ["SGPKitCPP"],
			path: "Sources/OBJC"),
        .testTarget(
            name: "SGPKitTests",
            dependencies: ["SGPKit"]),
    ]
)
