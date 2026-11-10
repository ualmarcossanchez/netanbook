import SwiftUI

/// Pantalla principal (Core): la biblioteca agrupada por estado.
///
/// La vista guarda los ViewModels y la configuración en `@State`, dibuja el
/// listado y delega las acciones. Desde cada fila se navega al detalle del libro.
struct BookListView: View {
    @State private var viewModel = BookListViewModel()
    @State private var config = AppConfig()
#if Progreso
    /// ViewModel de F1: independiente del listado y del libro.
    @State private var progressViewModel = ReadingProgressViewModel()
#endif

    var body: some View {
        NavigationStack {
            List {
                ForEach(ReadingStatus.allCases, id: \.self) { status in
                    Section(status.displayName) {
                        ForEach(viewModel.books(with: status)) { book in
                            bookRow(book: book)
                        }
                    }
                }
            }
            .toolbar {
#if Progreso
                Button("Progreso: \(config.showProgress ? "Sí" : "No")") {
                    config.showProgress.toggle()
                }
#endif
                Button("Añadir libro") {
                    viewModel.addSampleBook()
                }
            }
            .navigationTitle(Product.name)
        }
    }

    /// Una fila: enlace al detalle del libro, con menú contextual para borrarlo.
    private func bookRow(book: Book) -> some View {
        NavigationLink(destination: BookDetailView(book: binding(for: book))) {
            rowContent(for: book)
                .contextMenu {
                    Button("Eliminar libro") {
                        removeBook(id: book.id)
                    }
                }
        }
    }

    /// Contenido de la fila: el libro, los flags y las acciones como closures.
    private func rowContent(for book: Book) -> BookRowView {
#if Progreso
        return BookRowView(
            book: book,
            showProgress: config.showProgress,
            progress: progressViewModel.progress(for: book.id),
            changeStatus: { viewModel.advanceStatus(id: book.id) },
            advanceProgress: { progressViewModel.advance(bookID: book.id) }
        )
#else
        return BookRowView(
            book: book,
            showProgress: config.showProgress,
            changeStatus: { viewModel.advanceStatus(id: book.id) }
        )
#endif
    }

    /// Un enlace (`Binding`) para que el detalle edite el libro. No toca los
    /// datos: leer y escribir se traducen a métodos del ViewModel.
    private func binding(for book: Book) -> Binding<Book> {
        Binding(
            get: { viewModel.book(id: book.id) ?? book },
            set: { viewModel.updateBook($0) }
        )
    }

    /// Borra el libro. Si F1 está compilada, borra también su progreso:
    /// el Core no sabe que esos datos existen.
    private func removeBook(id: UUID) {
        viewModel.removeBook(id: id)
#if Progreso
        progressViewModel.removeProgress(bookID: id)
#endif
    }
}
