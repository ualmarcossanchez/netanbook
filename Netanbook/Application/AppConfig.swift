import Observation

/// Feature flags en ejecución de las cinco características comunes.
///
/// Es configuración de la aplicación, no datos de los libros. Todas empiezan
/// desactivadas: el producto arranca mostrando solo el Core. Que el código de
/// una característica exista en el producto lo decide la compilación
/// (`#if Progreso`); estos flags deciden si se muestra.
@Observable
final class AppConfig {
    /// F1 · Progreso.
    var showProgress = false
    /// F2 · Notas y citas.
    var showNotes = false
    /// F3 · Categorías.
    var showCategories = false
    /// F4 · Valoraciones y reseñas.
    var showReviews = false
    /// F5 · Estadísticas.
    var showStatistics = false
}

/// Producto de la familia que se ha compilado.
enum Product {
#if Progreso
    static let name = "Netanbook Progreso"
#else
    static let name = "Netanbook"
#endif
}
