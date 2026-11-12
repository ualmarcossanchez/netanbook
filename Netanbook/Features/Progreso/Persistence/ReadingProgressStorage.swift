#if Progreso
import Foundation

/// Almacenamiento del progreso de lectura (F1).
///
/// Es de la característica, no del Core: `BookStorageProvider` no sabe que el
/// progreso existe. Si F1 no se compila, este fichero queda vacío.
protocol ReadingProgressStorage {
    func loadProgress() throws -> [ReadingProgress]
    func saveProgress(_ progress: [ReadingProgress]) throws
}

/// Guarda el progreso en su propio fichero JSON, junto al de los libros.
final class JSONReadingProgressStorage: ReadingProgressStorage {
    private let fileURL: URL

    init(filename: String = "netanbook-progreso.json") {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = documents.appendingPathComponent(filename)
    }

    func loadProgress() throws -> [ReadingProgress] {
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode([ReadingProgress].self, from: data)
    }

    func saveProgress(_ progress: [ReadingProgress]) throws {
        let data = try JSONEncoder().encode(progress)
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: fileURL)
    }
}
#endif
