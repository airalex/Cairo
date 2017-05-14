import PackageDescription

let package = Package(
    name: "Cairo",
    targets: [
        Target(
            name: "Cairo")
    ],
    dependencies: [
        .Package(url: "https://github.com/airalex/CCairo.git", majorVersion: 1),
        .Package(url: "https://github.com/airalex/CFontConfig.git", majorVersion: 1),
        .Package(url: "https://github.com/airalex/CFreeType.git", majorVersion: 1)
    ],
    exclude: ["Xcode", "Sources/CairoUnitTests"]
)
