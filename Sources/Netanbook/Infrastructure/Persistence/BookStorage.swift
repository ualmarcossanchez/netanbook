// Infrastructure · Persistence — diseño previsto, sin implementación todavía.
//
// La persistencia local es obligatoria en el Core (M6), pero la tecnología
// (Core Data, SwiftData o JSON) se fijará antes de implementarla. Este
// protocolo deja el Core independiente de esa decisión: el ViewModel
// pedirá y entregará `[Book]` sin saber cómo se guardan.

/// Almacenamiento local de la biblioteca.
protocol BookStorage {
    func loadBooks() throws -> [Book]
    func saveBooks(_ books: [Book]) throws
}
