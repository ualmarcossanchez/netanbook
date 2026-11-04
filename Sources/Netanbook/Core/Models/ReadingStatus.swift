/// Estado de lectura de un libro (Core).
///
/// Tiene exactamente tres valores. `CaseIterable` permite recorrerlos
/// (por ejemplo, para agrupar el listado) y el `rawValue` es el texto
/// legible que se muestra en la interfaz.
enum ReadingStatus: String, CaseIterable, Sendable {
    case pending = "Pendiente"
    case reading = "Leyendo"
    case finished = "Terminado"

    /// Texto legible para la interfaz.
    var displayName: String { rawValue }
}
