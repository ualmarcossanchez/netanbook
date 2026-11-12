import SwiftUI

/// Detalle de un libro (Core).
///
/// Recibe un enlace (`@Binding`) al libro del listado: lo que se edita aquí
/// cambia el libro del ViewModel, sin copias. La vista no conoce el ViewModel.
struct BookDetailView: View {
    @Binding var book: Book

    var body: some View {
        Form {
            TextField("Título del libro", text: $book.title)
            Picker("Estado de lectura", selection: $book.status) {
                ForEach(ReadingStatus.allCases, id: \.self) { status in
                    Text(status.displayName).tag(status)
                }
            }
            Text("Autor: \(book.author ?? "Autor desconocido")")
                .bookCaption()
        }
        .navigationTitle(book.title)
    }
}
