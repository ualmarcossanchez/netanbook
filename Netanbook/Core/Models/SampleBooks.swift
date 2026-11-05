import Foundation

/// Libros de ejemplo del Core.
///
/// Tienen identificadores fijos para que una feature (por ejemplo, F1 Progreso)
/// pueda asociarles sus propios datos de ejemplo sin añadir nada a `Book`.
extension Book {
    enum SampleID {
        static let cienAnos = UUID(uuidString: "0B1C2D3E-0001-4000-8000-000000000001")!
        static let nombreDelViento = UUID(uuidString: "0B1C2D3E-0002-4000-8000-000000000002")!
        static let lazarillo = UUID(uuidString: "0B1C2D3E-0003-4000-8000-000000000003")!
    }

    static let samples: [Book] = [
        Book(id: SampleID.cienAnos, title: "Cien años de soledad",
             author: "Gabriel García Márquez", status: .finished),
        Book(id: SampleID.nombreDelViento, title: "El nombre del viento",
             author: "Patrick Rothfuss", status: .reading),
        Book(id: SampleID.lazarillo, title: "Lazarillo de Tormes"),
    ]
}
