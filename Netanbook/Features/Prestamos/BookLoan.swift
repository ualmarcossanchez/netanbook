import Foundation

// Original · Prestamos (opcional) — boceto de sesión 3, sin funcionalidad todavía.
// Saber a quién se ha prestado un libro físico y cuándo debe volver.
//
// Relación con el libro: 1 libro → 0..N préstamos (como mucho uno abierto).

/// Préstamo de un libro a otra persona.
struct BookLoan: Identifiable, Sendable {
    let id: UUID

    /// Libro prestado (`Book.id`).
    let bookID: UUID

    /// Persona que tiene el libro. Obligatorio.
    var borrowerName: String

    var loanDate: Date

    /// Fecha prevista de devolución, si se ha acordado.
    var dueDate: Date?

    /// Fecha real de devolución; `nil` mientras el préstamo siga abierto.
    var returnedDate: Date?
}
