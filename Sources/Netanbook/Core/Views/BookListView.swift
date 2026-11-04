import SwiftCrossUI

/// Pantalla principal (Core): el listado de libros agrupado por estado.
///
/// La vista no guarda libros: los lee del `BookListViewModel`.
/// Recorre `ReadingStatus.allCases` para crear un grupo por estado.
struct BookListView: View {
    @State private var viewModel = BookListViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Mi biblioteca")
                .font(.title)

            ForEach(ReadingStatus.allCases, id: \.self) { status in
                BookSectionView(
                    status: status,
                    books: viewModel.books(with: status)
                )
            }
        }
        .padding()
    }
}

/// Grupo del listado con los libros de un estado.
struct BookSectionView: View {
    let status: ReadingStatus
    let books: [Book]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(status.displayName)
                .font(.headline)

            if books.isEmpty {
                Text("Sin libros")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                ForEach(books) { book in
                    BookRowView(book: book)
                }
            }
        }
    }
}
