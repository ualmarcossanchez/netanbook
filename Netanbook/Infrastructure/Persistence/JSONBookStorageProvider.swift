import Foundation

/// Guarda los libros en un fichero JSON en la carpeta Documentos del usuario.
/// Funciona igual en macOS, Linux y Windows.
final class JSONBookStorageProvider: BookStorageProvider {
    private let fileURL: URL

    init(filename: String = "netanbook-libros.json") {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = documents.appendingPathComponent(filename)
    }

    func loadBooks() async throws -> [Book] {
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode([Book].self, from: data)
    }

    func saveBooks(_ books: [Book]) async throws {
        let data = try JSONEncoder().encode(books)
        // La carpeta Documentos no existe en todos los sistemas (por ejemplo, un Linux mínimo).
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: fileURL)
    }
}
