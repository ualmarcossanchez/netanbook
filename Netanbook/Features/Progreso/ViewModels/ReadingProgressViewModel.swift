#if Progreso
import Foundation
import Observation

/// ViewModel de F1 · Progreso.
///
/// Guarda el progreso de cada libro, indexado por `Book.id`. Es independiente
/// del ViewModel del listado: el Core no sabe que existe.
@Observable
final class ReadingProgressViewModel {
    /// Progreso de cada libro. Solo este ViewModel puede modificarlo.
    private(set) var progressByBook: [UUID: ReadingProgress] = [:]

    init(progress: [ReadingProgress] = ReadingProgress.samples) {
        for item in progress {
            progressByBook[item.bookID] = item
        }
    }

    /// Progreso de un libro, o `nil` si todavía no tiene.
    func progress(for bookID: UUID) -> ReadingProgress? {
        progressByBook[bookID]
    }

    /// Avanza la página actual de un libro sin pasar del total.
    /// Si el libro aún no tenía progreso, lo empieza.
    func advance(bookID: UUID, by pages: Int = 10) {
        var item = progressByBook[bookID]
            ?? ReadingProgress(bookID: bookID, totalPages: nil, currentPage: 0)
        let next = item.currentPage + pages
        if let total = item.totalPages {
            item.currentPage = min(next, total)
        } else {
            item.currentPage = next
        }
        progressByBook[bookID] = item
    }

    /// Borra el progreso de un libro (cuando el libro se elimina del listado).
    func removeProgress(bookID: UUID) {
        progressByBook[bookID] = nil
    }
}
#endif
