import Foundation

// Original · ImportarExportar (opcional) — boceto de sesión 3, sin funcionalidad todavía.
// Exportar la biblioteca a CSV e importarla, también desde Goodreads,
// para no quedar atrapado en la app.
//
// Relación con el libro: cada fila del CSV se corresponde con un `Book` del
// Core. Solo usa los campos del Core, así funciona sin ninguna otra feature.

/// Formato de fichero admitido.
enum CSVFormat: String, CaseIterable, Sendable {
    case netanbook = "Netanbook"
    case goodreads = "Goodreads"
}

/// Fila de un fichero CSV con los datos del Core de un libro.
struct CSVBookRecord: Sendable {
    var title: String
    var author: String?

    /// Texto del estado tal como aparece en el fichero
    /// (en Goodreads: "to-read", "currently-reading", "read").
    var statusText: String
}
