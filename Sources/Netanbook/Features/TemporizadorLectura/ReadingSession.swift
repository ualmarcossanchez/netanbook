import Foundation

// Original · TemporizadorLectura (opcional) — boceto de sesión 3, sin funcionalidad todavía.
// Medir con un temporizador el tiempo real dedicado a cada libro.
//
// Relación con el libro: 1 libro → 0..N sesiones de lectura.

/// Sesión de lectura cronometrada.
struct ReadingSession: Identifiable, Sendable {
    let id: UUID

    /// Libro que se está leyendo (`Book.id`).
    let bookID: UUID

    let startDate: Date

    /// `nil` mientras el temporizador siga en marcha.
    var endDate: Date?
}
