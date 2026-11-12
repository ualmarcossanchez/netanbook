import Foundation
import Observation

/// Feature flags en ejecución de las cinco características comunes.
///
/// Es configuración de la aplicación, no datos de los libros. Todas empiezan
/// desactivadas: el producto arranca mostrando solo el Core. Que el código de
/// una característica exista en el producto lo decide la compilación
/// (`#if Progreso`); estos flags deciden si se muestra.
///
/// Cada flag se guarda en `UserDefaults` al cambiar, así que se conserva al
/// cerrar y volver a abrir la app. La app crea una sola configuración y la
/// comparte por el entorno con el listado y con Ajustes.
@Observable
final class AppConfig {
    /// F1 · Progreso.
    var showProgress: Bool {
        didSet { store(showProgress, forKey: "showProgress") }
    }
    /// F2 · Notas y citas.
    var showNotes: Bool {
        didSet { store(showNotes, forKey: "showNotes") }
    }
    /// F3 · Categorías.
    var showCategories: Bool {
        didSet { store(showCategories, forKey: "showCategories") }
    }
    /// F4 · Valoraciones y reseñas.
    var showReviews: Bool {
        didSet { store(showReviews, forKey: "showReviews") }
    }
    /// F5 · Estadísticas.
    var showStatistics: Bool {
        didSet { store(showStatistics, forKey: "showStatistics") }
    }

    @ObservationIgnored private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        // `object(forKey:)` distingue «apagado» de «nunca guardado»: sin valor
        // guardado, el flag empieza desactivado.
        showProgress = defaults.object(forKey: "showProgress") as? Bool ?? false
        showNotes = defaults.object(forKey: "showNotes") as? Bool ?? false
        showCategories = defaults.object(forKey: "showCategories") as? Bool ?? false
        showReviews = defaults.object(forKey: "showReviews") as? Bool ?? false
        showStatistics = defaults.object(forKey: "showStatistics") as? Bool ?? false
    }

    private func store(_ value: Bool, forKey key: String) {
        defaults.set(value, forKey: key)
        // En Linux y Windows, UserDefaults escribe en disco más tarde: lo forzamos ya.
        defaults.synchronize()
    }
}

/// Producto de la familia que se ha compilado.
enum Product {
#if Progreso
    static let name = "Netanbook Progreso"
#else
    static let name = "Netanbook"
#endif
}
