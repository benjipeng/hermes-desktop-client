// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "HermesDashboard",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "HermesDashboard", targets: ["HermesDashboard"])
    ],
    targets: [
        .executableTarget(
            name: "HermesDashboard",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("WebKit")
            ]
        ),
        .testTarget(
            name: "HermesDashboardTests",
            dependencies: ["HermesDashboard"]
        )
    ]
)

