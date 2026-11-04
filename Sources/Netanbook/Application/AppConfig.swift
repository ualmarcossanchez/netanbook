// Configuración del producto — catálogo de features de la línea de productos.
//
// Sesión 3: solo declara qué features existen y qué variantes se pueden
// formar. Todavía no se usa: el primer feature flag llega en la sesión 4.
//
// Todas las features son opcionales e independientes (no hay grupo OR):
// un conjunto vacío es un producto válido, la variante Base (solo Core).

/// Features variables de Netanbook.
enum Feature: String, CaseIterable, Sendable {
    // Comunes (F1–F5)
    case progreso = "Progreso"
    case notasYCitas = "Notas y citas"
    case categorias = "Categorías"
    case valoracionesYResenas = "Valoraciones y reseñas"
    case estadisticas = "Estadísticas"

    // Originales (una por integrante)
    case prestamos = "Préstamos"
    case objetivoAnual = "Objetivo anual"
    case temporizadorLectura = "Temporizador de lectura"
    case importarExportar = "Importar y exportar CSV"
}

/// Features activas en un producto concreto de la familia.
struct AppConfig: Sendable {
    var enabledFeatures: Set<Feature>

    /// Base: solo Core.
    static let base = AppConfig(enabledFeatures: [])

    /// Común: Core + F1–F5.
    static let comun = AppConfig(enabledFeatures: [
        .progreso, .notasYCitas, .categorias, .valoracionesYResenas, .estadisticas,
    ])

    /// Completa: Core + F1–F5 + originales.
    static let completa = AppConfig(enabledFeatures: Set(Feature.allCases))
}
