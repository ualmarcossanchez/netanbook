import Foundation

// F2 · NotasYCitas (opcional) — boceto de sesión 3, sin funcionalidad todavía.
//
// Relación con el libro: 1 libro → 0..N anotaciones.
// Cada anotación apunta a su libro con `bookID`; el libro no conoce sus notas.

/// Tipo de anotación.
enum NoteKind: String, CaseIterable, Sendable {
    case note = "Nota"
    case quote = "Cita"
}

/// Anotación personal (nota o cita) vinculada a un libro.
struct BookNote: Identifiable, Sendable {
    let id: UUID

    /// Libro al que pertenece (`Book.id`).
    let bookID: UUID

    var kind: NoteKind

    /// Texto de la nota o de la cita. Obligatorio.
    var text: String

    /// Página de la cita, si se conoce.
    var page: Int?

    let createdAt: Date
}
