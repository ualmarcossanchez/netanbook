import SwiftUI

/// Pantalla principal (Core): la biblioteca agrupada por estado.
///
/// La vista guarda los ViewModels en `@State`, dibuja el listado y delega las
/// acciones. Desde cada fila se navega al detalle del libro.
struct BookListView: View {
    @State private var viewModel: BookListViewModel
    /// La configuración la crea la app y llega por el entorno: es la misma que edita Ajustes.
    @Environment(AppConfig.self) private var config
#if Progreso
    /// ViewModel de F1: independiente del listado y del libro.
    @State private var progressViewModel = ReadingProgressViewModel()
#endif

    /// Por defecto, el ViewModel guarda en JSON. Las vistas previas le pasan
    /// uno con `MockBookStorageProvider`.
    init(viewModel: BookListViewModel = BookListViewModel()) {
        _viewModel = State(wrappedValue: viewModel)
    }

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
                Button("Añadir libro") {
                    viewModel.addSampleBook()
                }
            }
            .navigationTitle("Libros")
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

// Vista previa con almacenamiento en memoria: no lee ni escribe el JSON real.
#Preview {
    BookListView(viewModel: BookListViewModel(storageProvider: MockBookStorageProvider()))
        .environment(AppConfig())
}
