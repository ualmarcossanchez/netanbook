import Foundation

// F1 · Progreso (opcional) — boceto de sesión 3, sin funcionalidad todavía.
//
// Relación con el libro: 1 libro → 0..1 progreso.
// El progreso no está dentro de `Book`: si F1 no se incluye en un producto,
// el Core sigue funcionando y estos datos simplemente no existen.

/// Progreso de lectura de un libro.
struct ReadingProgress: Identifiable, Sendable {
    /// Un progreso por libro: su identidad es la del libro.
    var id: UUID { bookID }

    /// Libro al que pertenece (`Book.id`).
    let bookID: UUID

    /// Total de páginas. Puede faltar: sin un total válido no hay porcentaje.
    var totalPages: Int?

    /// Página por la que va el lector.
    var currentPage: Int
}
