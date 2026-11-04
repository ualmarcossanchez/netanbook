import DefaultBackend
import SwiftCrossUI

/// Punto de entrada de Netanbook.
/// La aplicación solo conoce la pantalla principal del Core.
@main
struct NetanbookApp: App {
    var body: some Scene {
        WindowGroup("Netanbook") {
            BookListView()
        }
    }
}
