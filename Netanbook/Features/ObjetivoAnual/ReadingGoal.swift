import Foundation

// Original · ObjetivoAnual (opcional) — boceto de sesión 3, sin funcionalidad todavía.
// Fijar un reto de libros terminados en un año y seguir su avance.
//
// Relación con el libro: el objetivo cuenta libros del Core que pasan a
// `.finished`; no añade campos a `Book`.

/// Reto de lectura de un año.
struct ReadingGoal: Identifiable, Sendable {
    /// Un objetivo por año.
    var id: Int { year }

    let year: Int

    /// Número de libros que el usuario quiere terminar ese año.
    var targetBooks: Int

    /// Libros terminados que cuentan para el reto (`Book.id`).
    var completedBookIDs: Set<UUID>
}
