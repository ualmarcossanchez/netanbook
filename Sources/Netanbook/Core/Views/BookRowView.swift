import SwiftCrossUI

/// Fila del listado: título y autor de un libro.
/// Si el libro no tiene autor, se muestra un texto alternativo.
struct BookRowView: View {
    let book: Book

    var body: some View {
        VStack(alignment: .leading) {
            Text(book.title)
            Text(book.author ?? "Autor desconocido")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}
