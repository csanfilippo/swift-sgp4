// swift-tools-version: 5.5

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

#if swift(>=5.6)
package.dependencies.append(
	.package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
)
#endif
