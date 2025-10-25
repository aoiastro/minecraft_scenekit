import PackageDescription

let package = Package(
    name: "minecraft_swiftUI",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .executable(
            name: "minecraft_swiftUI",
            targets: ["minecraft_swiftUI"]
        )
    ],
    dependencies: [
        
    ],
    targets: [
        .executableTarget(
            name: "minecraft_swiftUI",
            dependencies: [],
            resources: [.copy("Resources")]
        )
    ]
)