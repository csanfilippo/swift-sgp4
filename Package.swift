// swift-tools-version: 5.9

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
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.0")
	],
	targets: [
		.target(
			name: "SGPKit",
			dependencies: ["SGPKitOBJC"],
            exclude: privacyManifestExclude,
            resources: privacyManifestResource,
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
		.target(
			name: "SGPKitCPP",
			path: "Sources/sgp4-147b1ae"
		),
		.target(
			name: "SGPKitOBJC",
			dependencies: ["SGPKitCPP"],
			path: "Sources/OBJC"
        ),
		.testTarget(
			name: "SGPKitTests",
			dependencies: [
				"SGPKit"
			],
			resources: [
				.copy("Mocks")
			],
            swiftSettings: [.interoperabilityMode(.Cxx)]
		)
	],
    cxxLanguageStandard: .cxx17
)
