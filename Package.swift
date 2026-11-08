// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TimerCore",
    products: [.library(name: "TimerCore", targets: ["TimerCore"])],
    targets: [
        .target(name: "TimerCore", path: "Timer", exclude: ["TimerApp.swift", "TimerModel.swift", "TimerScreen.swift"], sources: ["TimerEngine.swift"]),
        .testTarget(name: "TimerCoreTests", dependencies: ["TimerCore"], path: "Tests")
    ]
)
