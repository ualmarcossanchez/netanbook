import Foundation

// F4 · ValoracionesYResenas (opcional) — boceto de sesión 3, sin funcionalidad todavía.
//
// Relación con el libro: 1 libro → 0..1 valoración global.

/// Valoración y reseña global de un libro.
struct BookReview: Identifiable, Sendable {
    /// Una valoración por libro: su identidad es la del libro.
    var id: UUID { bookID }

    /// Libro valorado (`Book.id`).
    let bookID: UUID

    /// Puntuación de 1 a 5 (ver `ratingRange`).
    var rating: Int

    /// Reseña breve. Opcional: se puede puntuar sin escribir reseña.
    var text: String?

    /// Rango válido de la puntuación.
    static let ratingRange = 1...5
}
