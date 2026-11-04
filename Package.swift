// swift-tools-version: 6.1
import PackageDescription

// Netanbook: nuestra BookApp para la asignatura de Líneas de Productos Software.
// Sesión 3: un único target con la estructura
// Application / Core (Models, Views, ViewModels) / Features / Infrastructure.
// La interfaz usa SwiftCrossUI para que funcione en Windows, Linux y macOS.
let package = Package(
    name: "Netanbook",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "Netanbook", targets: ["Netanbook"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/moreSwift/swift-cross-ui.git",
            .upToNextMinor(from: "0.10.0")
        ),
    ],
    targets: [
        .executableTarget(
            name: "Netanbook",
            dependencies: [
                .product(name: "SwiftCrossUI", package: "swift-cross-ui"),
                .product(name: "DefaultBackend", package: "swift-cross-ui"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
