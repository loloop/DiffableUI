// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "DiffableUI",
  platforms: [
    .iOS(.v14),
  ],
  products: [
    .library(name: "DiffableUI", targets: ["DiffableUI"]),
  ],
  targets: [
    .target(name: "DiffableUI"),
    // No tests yet, sorry!
    // .testTarget(name: "DiffableUITests", dependencies: ["DiffableUI"]),
  ]
)
