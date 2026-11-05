import SwiftUI

/// Punto de entrada de Netanbook.
///
/// En macOS usa el SwiftUI de Apple (proyecto de Xcode). En Linux y Windows,
/// `import SwiftUI` trae SwiftOpenUI a través del módulo `Compat/SwiftUI`.
@main
struct NetanbookApp: App {
    var body: some Scene {
        WindowGroup(Product.name) {
            BookListView()
        }
    }
}
