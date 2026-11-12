import SwiftUI

/// Punto de entrada de Netanbook.
///
/// En macOS usa el SwiftUI de Apple (proyecto de Xcode). En Linux y Windows,
/// `import SwiftUI` trae SwiftOpenUI a través del módulo `Compat/SwiftUI`.
@main
struct NetanbookApp: App {
    /// Una sola configuración para toda la app: la comparten Libros y Ajustes.
    @State private var config = AppConfig()
    @State private var selection: String? = "libros"

    var body: some Scene {
        WindowGroup(Product.name) {
#if os(iOS)
            TabView {
                BookListView()
                    .tabItem { Label("Libros", systemImage: "books.vertical") }
                SettingsView()
                    .tabItem { Label("Ajustes", systemImage: "gearshape") }
            }
            .environment(config)
#else
            NavigationSplitView {
                List(selection: $selection) {
                    NavigationLink(value: "libros") {
                        Label("Libros", systemImage: "books.vertical")
                    }
                    NavigationLink(value: "ajustes") {
                        Label("Ajustes", systemImage: "gearshape")
                    }
                }
            } detail: {
                switch selection {
                case "libros":
                    BookListView()
                case "ajustes":
                    SettingsView()
                default:
                    Text("Elige una opción")
                }
            }
            .environment(config)
#endif
        }
    }
}
