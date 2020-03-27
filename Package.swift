// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "Sio",
	platforms: [
		.macOS(.v10_11), .iOS(.v10),
	],
	products: [
		// Products define the executables and libraries produced by a package, and make them visible to other packages.
		.library(
			name: "Sio",
			targets: ["Sio"]
		),
		.library(
			name: "SioCodec",
			targets: ["SioCodec"]
		),
		.library(
			name: "SioValueStore",
			targets: ["SioValueStore"]
		),
		.library(
			name: "SioEffects",
			targets: ["SioEffects"]
		),
		.library(
			name: "SioNetwork",
			targets: ["SioNetwork"]
		)
	],
	dependencies: [
	  .package(name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.7.0")
	],
	targets: [
		// Targets are the basic building blocks of a package. A target can define a module or a test suite.
		// Targets can depend on other targets in this package, and on products in packages which this package depends on.
		.target(
			name: "Sio",
			dependencies: [ ]),
		.testTarget(
			name: "SioTests",
			dependencies: ["Sio", "SioValueStore"]),
		
		.target(
			name: "SioCodec",
			dependencies: [ "Sio" ]),
		.testTarget(
			name: "SioCodecTests",
			dependencies: ["Sio", "SioCodec"]),
		
		.target(
			name: "SioValueStore",
			dependencies: [ "Sio", "SioCodec" ]),
		.testTarget(
			name: "SioValueStoreTests",
			dependencies: ["Sio", "SioCodec", "SioValueStore" ]),
		
		.target(
			name: "SioEffects",
			dependencies: [ "Sio", "SioCodec", "SioValueStore" ]),
		.testTarget(
			name: "SioEffectsTests",
			dependencies: ["Sio", "SioEffects", "SioCodec", "SioValueStore" ]),
		
		.target(
			name: "SioNetwork",
			dependencies: [ "Sio", "SioCodec", "SioValueStore", "SioEffects" ]),
		.testTarget(
			name: "SioNetworkTests",
			dependencies: ["Sio", "SioNetwork", "SioCodec", "SioValueStore", "SioEffects", "SnapshotTesting" ])
	]
)
