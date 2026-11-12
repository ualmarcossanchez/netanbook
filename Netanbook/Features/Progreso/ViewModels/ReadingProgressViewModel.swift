#if Progreso
import Foundation
import Observation

/// ViewModel de F1 · Progreso.
///
/// Guarda el progreso de cada libro, indexado por `Book.id`. Es independiente
/// del ViewModel del listado: el Core no sabe que existe. Cada cambio se guarda
/// en el almacenamiento propio de F1 (`ReadingProgressStorage`).
@Observable
final class ReadingProgressViewModel {
    /// Progreso de cada libro. Solo este ViewModel puede modificarlo.
    private(set) var progressByBook: [UUID: ReadingProgress] = [:]

    @ObservationIgnored private let storage: ReadingProgressStorage

    /// Carga el progreso guardado. Si aún no hay nada guardado, empieza con el
    /// progreso de ejemplo de los libros de ejemplo.
    init(storage: ReadingProgressStorage = JSONReadingProgressStorage()) {
        self.storage = storage
        let progress = (try? storage.loadProgress()) ?? ReadingProgress.samples
        for item in progress {
            progressByBook[item.bookID] = item
        }
    }

    private func save() {
        do {
            try storage.saveProgress(Array(progressByBook.values))
        } catch {
            print("No se ha guardado el progreso: \(error)")
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
        save()
    }

    /// Borra el progreso de un libro (cuando el libro se elimina del listado).
    func removeProgress(bookID: UUID) {
        progressByBook[bookID] = nil
        save()
    }
}
#endif
