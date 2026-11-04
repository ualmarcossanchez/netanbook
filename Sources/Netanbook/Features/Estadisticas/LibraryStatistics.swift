// F5 · Estadisticas (opcional) — boceto de sesión 3, sin funcionalidad todavía.
//
// Relación con el libro: no guarda datos propios. Se calcula a partir de la
// colección de libros del Core (`[Book]`) y de su estado, sin exigir F1.

/// Resumen de la biblioteca.
struct LibraryStatistics: Sendable {
    /// Total de libros.
    var totalBooks: Int

    /// Número de libros en cada estado.
    var pendingCount: Int
    var readingCount: Int
    var finishedCount: Int
}
