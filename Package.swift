// swift-tools-version: 5.10

import PackageDescription

#if canImport(Darwin)
let privacyManifestExclude: [String] = []
let privacyManifestResource: [PackageDescription.Resource] = [.copy("PrivacyInfo.xcprivacy")]
#else
// Exclude on other platforms to avoid build warnings.
let privacyManifestExclude: [String] = ["PrivacyInfo.xcprivacy"]
let privacyManifestResource: [PackageDescription.Resource] = []
#endif

let package = Package(
	name: "SGPKit",
    platforms: [.iOS(.v13), .macOS(.v13)],
	products: [
		.library(
			name: "SGPKit",
			targets: ["SGPKit"])
	],
	dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.0"),
        .package(url: "https://github.com/apple/swift-numerics", from: "1.1.0"),
	],
	targets: [
		.target(
			name: "SGPKit",
			dependencies: ["SGP4LibWrapper"],
            exclude: privacyManifestExclude,
            resources: privacyManifestResource
        ),
        .target(
            name: "SGP4LibWrapper",
            dependencies: ["SGPKitCPP"],
            cxxSettings: [.headerSearchPath("../sgp4Lib/include")]
        ),
		// SwiftPM puts a target's public headers on the search path of every Swift module above it.
		// The headers-free target root keeps sgp4's include/ off that path: there its headers would
		// shadow system ones on case-insensitive filesystems (Util.h for Glibc's <util.h>) and fail
		// to compile as C.
		.target(
			name: "SGPKitCPP",
			path: "Sources/sgp4Lib",
			exclude: ["LICENSE", "UPSTREAM_REVISION"],
			publicHeadersPath: ".",
			cxxSettings: [.headerSearchPath("include")]
		),
		.testTarget(
			name: "SGPKitTests",
			dependencies: [
				"SGPKit",
                .product(name: "Numerics", package: "swift-numerics")
			],
			resources: [
				.copy("Fixtures/Mocks")
			]
		)
	],
    cxxLanguageStandard: .cxx17
)
