/// Estado de lectura de un libro (Core).
///
/// Tiene exactamente tres valores. `CaseIterable` permite recorrerlos para
/// agrupar el listado y el `rawValue` es el texto legible de la interfaz.
/// Es `Codable`: en el JSON se guarda ese mismo texto.
enum ReadingStatus: String, CaseIterable, Codable {
    case pending = "Pendiente"
    case reading = "Leyendo"
    case finished = "Terminado"

    /// Texto legible para la interfaz.
    var displayName: String { rawValue }

    /// Estado al que pasa el libro al pulsar su botón en la fila:
    /// Pendiente → Leyendo → Terminado → Pendiente.
    var next: ReadingStatus {
        switch self {
        case .pending: return .reading
        case .reading: return .finished
        case .finished: return .pending
        }
    }

    /// Icono del estado. En Windows y Linux, SwiftOpenUI traduce estos
    /// nombres de SF Symbols a su fuente de iconos.
    var symbolName: String {
        switch self {
        case .pending: return "circle"
        case .reading: return "clock"
        case .finished: return "checkmark.circle.fill"
        }
    }
}
