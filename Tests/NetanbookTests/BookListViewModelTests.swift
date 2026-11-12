import Foundation
import XCTest
@testable import Netanbook

/// Pruebas del ViewModel del listado con `MockBookStorageProvider`: el ViewModel
/// solo conoce el protocolo, así que aquí no se toca ningún fichero.
@MainActor
final class BookListViewModelTests: XCTestCase {
    func testCargaLosLibrosDelAlmacenamiento() async {
        let storage = MockBookStorageProvider()
        let viewModel = BookListViewModel(storageProvider: storage)

        await viewModel.loadBooks()

        XCTAssertEqual(viewModel.books.map(\.title), ["Libro de prueba 1", "Libro de prueba 2"])
    }

    func testCadaCambioSeGuarda() async {
        let storage = MockBookStorageProvider()
        let viewModel = BookListViewModel(storageProvider: storage)
        await viewModel.loadBooks()
        let id = viewModel.books[0].id

        viewModel.advanceStatus(id: id)
        viewModel.addSampleBook()
        await viewModel.waitForPendingSave()

        XCTAssertEqual(storage.storedBooks.count, 3)
        XCTAssertEqual(storage.storedBooks[0].status, .reading)
    }

    func testEditarEnElDetalleYBorrarTambienSeGuardan() async {
        let storage = MockBookStorageProvider()
        let viewModel = BookListViewModel(storageProvider: storage)
        await viewModel.loadBooks()

        var edited = viewModel.books[0]
        edited.title = "Título editado"
        viewModel.updateBook(edited)
        viewModel.removeBook(id: viewModel.books[1].id)
        await viewModel.waitForPendingSave()

        XCTAssertEqual(storage.storedBooks.map(\.title), ["Título editado"])
    }

    func testUnTituloVacioNoSeGuarda() async {
        let storage = MockBookStorageProvider()
        let viewModel = BookListViewModel(storageProvider: storage)
        await viewModel.loadBooks()

        var edited = viewModel.books[0]
        edited.title = "   "
        viewModel.updateBook(edited)
        await viewModel.waitForPendingSave()

        XCTAssertEqual(viewModel.books[0].title, "Libro de prueba 1")
    }

    func testElLibroSeCodificaYDecodificaEnJSON() throws {
        let book = Book(title: "El nombre del viento", author: "Patrick Rothfuss", status: .reading)

        let data = try JSONEncoder().encode([book])
        let decoded = try JSONDecoder().decode([Book].self, from: data)

        XCTAssertEqual(decoded.first?.id, book.id)
        XCTAssertEqual(decoded.first?.title, book.title)
        XCTAssertEqual(decoded.first?.status, .reading)
    }
}
