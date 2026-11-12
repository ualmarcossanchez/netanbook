import Foundation
import Observation

/// ViewModel del listado de libros (Core).
///
/// Es el dueño de la colección y el único que la modifica. La vista solo lee
/// los libros y le delega las acciones. Al ser `@Observable`, la vista se
/// vuelve a dibujar cuando cambia `books`.
///
/// Carga y guarda los libros a través de `BookStorageProvider`: no sabe si
/// detrás hay un fichero JSON o un almacenamiento en memoria.
@Observable
final class BookListViewModel {
    /// Colección de libros. Solo el ViewModel puede modificarla. Cada cambio
    /// (estado, alta, baja o edición en el detalle) se guarda.
    private(set) var books: [Book] = Book.samples {
        didSet { if !isLoading { save() } }
    }

    /// No forma parte del estado que observa la vista: cambiar de almacenamiento
    /// no debe redibujar nada.
    @ObservationIgnored private let storageProvider: BookStorageProvider
    @ObservationIgnored private var loadTask: Task<Void, Never>?
    /// Lo que se acaba de leer del almacenamiento no hace falta volver a guardarlo.
    @ObservationIgnored private var isLoading = false
    @ObservationIgnored private var pendingSave: Task<Void, Never>?

    /// Por defecto guarda en JSON; en pruebas se le pasa un `MockBookStorageProvider`.
    /// Al crearse, carga los libros guardados.
    init(storageProvider: BookStorageProvider = JSONBookStorageProvider()) {
        self.storageProvider = storageProvider
        loadTask = Task { await load() }
    }

    /// Espera a que termine la carga inicial (la usan las pruebas).
    func loadBooks() async {
        await loadTask?.value
    }

    /// Carga los libros guardados. Si aún no hay nada guardado, se quedan los
    /// libros de ejemplo.
    private func load() async {
        do {
            let stored = try await storageProvider.loadBooks()
            isLoading = true
            books = stored
            isLoading = false
        } catch {
            print("No se han cargado libros guardados: \(error)")
        }
    }

    /// Guarda la lista completa. Cada guardado espera al anterior, para que
    /// lo último que se escribe sea siempre el último cambio.
    private func save() {
        let books = books
        let previous = pendingSave
        pendingSave = Task {
            await previous?.value
            do {
                try await storageProvider.saveBooks(books)
            } catch {
                print("No se han guardado los libros: \(error)")
            }
        }
    }

    /// Espera a que termine el último guardado pendiente (lo usan las pruebas).
    func waitForPendingSave() async {
        await pendingSave?.value
    }

    /// Libros con un estado concreto, para agrupar el listado.
    func books(with status: ReadingStatus) -> [Book] {
        books.filter { $0.status == status }
    }

    /// Cambia el estado de lectura de un libro. Lo busca por `id`, no por su
    /// posición, porque la posición cambia al agrupar, añadir o borrar.
    func changeStatus(id: UUID, to status: ReadingStatus) {
        guard let index = books.firstIndex(where: { $0.id == id }) else { return }
        books[index].status = status
    }

    /// Pasa el libro al siguiente estado: Pendiente → Leyendo → Terminado → Pendiente.
    func advanceStatus(id: UUID) {
        guard let book = books.first(where: { $0.id == id }) else { return }
        changeStatus(id: id, to: book.status.next)
    }

    /// Añade un libro de ejemplo (empieza como pendiente).
    func addSampleBook() {
        books.append(Book(title: "Libro de ejemplo \(books.count + 1)"))
    }

    /// Borra un libro del listado.
    func removeBook(id: UUID) {
        books.removeAll { $0.id == id }
    }

    /// El libro con ese `id`, si sigue en el listado.
    func book(id: UUID) -> Book? {
        books.first { $0.id == id }
    }

    /// Sustituye el libro que tiene el mismo `id` (lo usa el detalle al editar).
    /// Un título vacío no es válido: en ese caso se conserva el título anterior.
    func updateBook(_ book: Book) {
        guard let index = books.firstIndex(where: { $0.id == book.id }) else { return }
        var updated = book
        if !Book.isValidTitle(updated.title) {
            updated.title = books[index].title
        }
        books[index] = updated
    }
}
