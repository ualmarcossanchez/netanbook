// swift-tools-version: 6.2
// Paquete para Linux y Windows. Compila la MISMA carpeta Netanbook/ que usa Xcode
// (en Mac se abre Netanbook.xcodeproj y se usa el SwiftUI de Apple).
import PackageDescription

#if os(Linux)
let backend: Target.Dependency = .product(name: "BackendGTK4", package: "SwiftOpenUI")
#elseif os(Windows)
let backend: Target.Dependency = .product(name: "BackendWin32", package: "SwiftOpenUI")
#else
let backend: Target.Dependency? = nil
#endif

let package = Package(
    name: "Netanbook",
    // Productos de la línea: cada trait activo es una variable de compilación.
    //   swift run Netanbook                     → producto base (solo Core)
    //   swift run --traits Progreso Netanbook   → Netanbook Progreso (#if Progreso)
    // En Xcode, el mismo papel lo cumple el target «Netanbook Progreso».
    traits: [
        .trait(name: "Progreso", description: "F1 Progreso: páginas leídas de cada libro"),
    ],
    dependencies: [
        .package(url: "https://github.com/uallps/SwiftOpenUI.git", branch: "uallps"),
    ],
    targets: [
        // Sustituye al SwiftUI de Apple: `import SwiftUI` trae SwiftOpenUI y su backend.
        .target(
            name: "SwiftUI",
            dependencies: [.product(name: "SwiftOpenUI", package: "SwiftOpenUI")] + [backend].compactMap { $0 },
            path: "Compat/SwiftUI"
        ),
        // Mismos ajustes de Swift que el proyecto de Xcode.
        .executableTarget(
            name: "Netanbook",
            dependencies: ["SwiftUI"],
            path: "Netanbook",
            exclude: ["Assets.xcassets"],
            swiftSettings: [
                .swiftLanguageMode(.v5),
                .defaultIsolation(MainActor.self),
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
                .enableUpcomingFeature("MemberImportVisibility"),
            ]
        ),
        // Pruebas del ViewModel con MockBookStorageProvider: `swift test`.
        .testTarget(
            name: "NetanbookTests",
            dependencies: ["Netanbook"],
            path: "Tests/NetanbookTests",
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
    ]
)
