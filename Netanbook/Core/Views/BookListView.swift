import SwiftUI

/// Pantalla principal (Core): la biblioteca agrupada por estado.
///
/// La vista guarda los ViewModels y la configuración en `@State`, dibuja el
/// listado y delega las acciones. Las operaciones están en los ViewModels.
struct BookListView: View {
    @State private var viewModel = BookListViewModel()
    @State private var config = AppConfig()
#if Progreso
    /// ViewModel de F1: independiente del listado y del libro.
    @State private var progressViewModel = ReadingProgressViewModel()
#endif

    var body: some View {
        VStack {
            Text(Product.name)
                .font(.title2)
                .padding(.top)
#if Progreso
            Button("Progreso: \(config.showProgress ? "Sí" : "No")") {
                config.showProgress.toggle()
            }
#endif
            List {
                ForEach(ReadingStatus.allCases, id: \.self) { status in
                    Section(status.displayName) {
                        ForEach(viewModel.books(with: status)) { book in
                            row(for: book)
                        }
                    }
                }
            }
            Button("Añadir libro") {
                viewModel.addSampleBook()
            }
            .padding()
        }
    }

    /// Crea la fila con el libro, los flags y las acciones como closures.
    private func row(for book: Book) -> BookRowView {
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
}
