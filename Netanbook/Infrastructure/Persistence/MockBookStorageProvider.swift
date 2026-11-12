/// Almacenamiento en memoria, para pruebas y vistas previas: no escribe nada en disco.
final class MockBookStorageProvider: BookStorageProvider {
    /// Lo que hay «guardado». Las pruebas lo leen para comprobar qué se ha guardado.
    private(set) var storedBooks: [Book]

    init(books: [Book] = [
        Book(title: "Libro de prueba 1"),
        Book(title: "Libro de prueba 2", author: "Autora de prueba", status: .finished),
    ]) {
        storedBooks = books
    }

    func loadBooks() async throws -> [Book] {
        storedBooks
    }

    func saveBooks(_ books: [Book]) async throws {
        storedBooks = books
    }
}
