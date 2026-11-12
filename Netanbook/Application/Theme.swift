import SwiftUI

// El tema de Netanbook: colores y estilos en un solo sitio, añadidos con
// extensiones. Para cambiar el aspecto se toca este fichero, no las vistas.

extension Color {
    /// Color principal de Netanbook.
    static let bookAccent = Color(red: 0.45, green: 0.27, blue: 0.13)
}

/// Estilo del texto secundario de las filas (autor, progreso).
struct CaptionStyle: ViewModifier {
    var color: Color = .secondary

    func body(content: Content) -> some View {
        content
            .font(.caption)
            .foregroundColor(color)
    }
}

extension View {
    /// Aplica el estilo de texto secundario: `Text("…").bookCaption()`,
    /// o con otro color: `.bookCaption(color: .bookAccent)`.
    func bookCaption(color: Color = .secondary) -> some View {
        modifier(CaptionStyle(color: color))
    }
}

extension ReadingStatus {
    /// Color de cada estado de lectura. Es presentación, no modelo: por eso
    /// está aquí y no en `ReadingStatus.swift`.
    var color: Color {
        switch self {
        case .pending: return .gray
        case .reading: return .bookAccent
        case .finished: return .green
        }
    }
}
