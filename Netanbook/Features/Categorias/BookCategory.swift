import Foundation

// F3 · Categorias (opcional) — boceto de sesión 3, sin funcionalidad todavía.
//
// Relación con el libro: N libros ↔ M categorías.
// La asociación se guarda aparte (`BookCategoryAssignment`), así ni `Book`
// ni `BookCategory` dependen el uno del otro.

/// Categoría creada por el usuario (género, curso, tema...).
struct BookCategory: Identifiable, Hashable, Sendable {
    let id: UUID

    /// Nombre de la categoría. Obligatorio.
    var name: String
}

/// Asignación de un libro a una categoría.
struct BookCategoryAssignment: Hashable, Sendable {
    /// Libro asignado (`Book.id`).
    let bookID: UUID

    /// Categoría asignada (`BookCategory.id`).
    let categoryID: UUID
}
