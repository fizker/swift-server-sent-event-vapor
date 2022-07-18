// swift-tools-version: 5.6

import PackageDescription

let package = Package(
	name: "swift-server-sent-event-vapor",
	platforms: [
		.macOS(.v10_15),
	],
	products: [
		.library(
			name: "ServerSentEventVapor",
			targets: ["ServerSentEventVapor"]
		),
	],
	dependencies: [
		.package(url: "https://github.com/vapor/vapor.git", from: "4.62.1"),
		.package(url: "https://github.com/fizker/swift-server-sent-event-models.git", from: "0.0.1"),
	],
	targets: [
		.target(
			name: "ServerSentEventVapor",
			dependencies: [
				.product(name: "Vapor", package: "vapor"),
				.product(name: "ServerSentEventModels", package: "swift-server-sent-event-models"),
			]
		),
	]
)
