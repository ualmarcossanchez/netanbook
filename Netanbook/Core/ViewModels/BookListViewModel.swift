import Foundation
import Observation

/// ViewModel del listado de libros (Core).
///
/// Es el dueño de la colección y el único que la modifica. La vista solo lee
/// los libros y le delega las acciones. Al ser `@Observable`, la vista se
/// vuelve a dibujar cuando cambia `books`.
@Observable
final class BookListViewModel {
    /// Colección de libros. Solo el ViewModel puede modificarla.
    private(set) var books: [Book]

    init(books: [Book] = Book.samples) {
        self.books = books
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
