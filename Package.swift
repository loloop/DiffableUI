// swift-tools-version: 6.0
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
    // UIKit-only: run with `xcodebuild test` on an iOS Simulator, not `swift test`.
    .testTarget(name: "DiffableUITests", dependencies: ["DiffableUI"]),
  ]
)
