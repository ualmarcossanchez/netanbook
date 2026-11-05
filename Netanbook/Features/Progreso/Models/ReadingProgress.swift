#if Progreso
import Foundation

// F1 · Progreso (opcional). Solo se compila con la variable `Progreso`:
// el target «Netanbook Progreso» de Xcode o `--traits Progreso` en SwiftPM.
//
// Relación con el libro: 1 libro → 0..1 progreso. El progreso no está dentro
// de `Book`: si F1 no se compila, el Core sigue igual y estos datos no existen.

/// Progreso de lectura de un libro.
struct ReadingProgress: Identifiable {
    /// Un progreso por libro: su identidad es la del libro.
    var id: UUID { bookID }

    /// Libro al que pertenece (`Book.id`).
    let bookID: UUID

    /// Total de páginas. Puede faltar: sin un total válido no hay porcentaje.
    var totalPages: Int?

    /// Página por la que va el lector.
    var currentPage: Int

    /// Fracción leída (de 0 a 1). Solo existe si hay un total válido.
    var fractionRead: Double? {
        guard let totalPages, totalPages > 0 else { return nil }
        return min(Double(currentPage) / Double(totalPages), 1)
    }
}

extension ReadingProgress {
    /// Progreso de ejemplo de los libros de ejemplo del Core.
    static let samples: [ReadingProgress] = [
        ReadingProgress(bookID: Book.SampleID.cienAnos, totalPages: 471, currentPage: 471),
        ReadingProgress(bookID: Book.SampleID.nombreDelViento, totalPages: 662, currentPage: 250),
        ReadingProgress(bookID: Book.SampleID.lazarillo, totalPages: 96, currentPage: 0),
    ]
}
#endif
