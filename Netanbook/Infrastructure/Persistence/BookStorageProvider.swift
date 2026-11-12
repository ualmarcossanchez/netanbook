/// Contrato de almacenamiento de la biblioteca.
///
/// El ViewModel del listado solo conoce este protocolo, así que se puede cambiar
/// dónde se guardan los libros (JSON, memoria, SwiftData…) sin tocarlo.
protocol BookStorageProvider {
    func loadBooks() async throws -> [Book]
    func saveBooks(_ books: [Book]) async throws
}
