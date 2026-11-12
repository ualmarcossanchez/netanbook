import Foundation

/// Libro: la entidad central del Core de Netanbook.
///
/// Solo contiene lo que comparten todos los productos de la familia
/// (identificador, título, autor y estado). Los datos de las features
/// (progreso, notas, categorías, valoraciones...) no viven aquí: cada
/// feature guarda los suyos y los asocia al libro mediante `id`.
///
/// Es `Codable`: se puede guardar y leer en JSON.
struct Book: Identifiable, Codable {
    /// Identidad única y estable. Es `let` porque no cambia aunque se
    /// edite el libro; así la lista y las features lo distinguen siempre.
    let id: UUID

    /// Obligatorio y no vacío (ver `isValidTitle(_:)`).
    var title: String

    /// Opcional: un libro concreto puede no tener autor conocido.
    var author: String?

    /// Estado de lectura. Un libro nuevo empieza como pendiente.
    var status: ReadingStatus

    init(
        id: UUID = UUID(),
        title: String,
        author: String? = nil,
        status: ReadingStatus = .pending
    ) {
        self.id = id
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        // Un autor en blanco se guarda como ausente (nil).
        let trimmedAuthor = author?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.author = (trimmedAuthor?.isEmpty ?? true) ? nil : trimmedAuthor
        self.status = status
    }

    /// Regla del dominio: el título no puede estar vacío.
    static func isValidTitle(_ title: String) -> Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
