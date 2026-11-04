import Foundation
import Observation

/// ViewModel del listado de libros (Core).
///
/// Es el dueño de la colección de libros: la vista solo la lee y le
/// delega las acciones. Al ser `@Observable`, la vista se vuelve a dibujar
/// cuando cambia `books`. Es el único componente que modificará el Model
/// (cambiar estado, añadir y eliminar llegarán en la sesión 4).
@Observable
final class BookListViewModel {
    /// Colección de libros. Solo el ViewModel puede modificarla.
    private(set) var books: [Book]

    init(books: [Book] = BookListViewModel.sampleBooks) {
        self.books = books
    }

    /// Libros con un estado concreto, para agrupar el listado.
    func books(with status: ReadingStatus) -> [Book] {
        books.filter { $0.status == status }
    }

    /// Libros de ejemplo mientras no haya alta ni persistencia.
    static var sampleBooks: [Book] {
        [
            Book(title: "Cien años de soledad", author: "Gabriel García Márquez", status: .finished),
            Book(title: "El nombre del viento", author: "Patrick Rothfuss", status: .reading),
            Book(title: "Lazarillo de Tormes"),
        ]
    }
}
