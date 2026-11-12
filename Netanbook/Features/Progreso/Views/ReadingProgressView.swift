#if Progreso
import SwiftUI

/// Vista de F1 · Progreso para un libro: barra, páginas, porcentaje y un botón
/// para avanzar. Como la fila, no conoce ningún ViewModel.
struct ReadingProgressView: View {
    let progress: ReadingProgress?
    let advance: () -> Void

    var body: some View {
        HStack {
            if let fraction = progress?.fractionRead {
                ProgressView(value: fraction)
                    .frame(width: 120)
            }
            Text(summary)
                .bookCaption()
            Button("+10 páginas", action: advance)
        }
    }

    /// Texto del progreso: el porcentaje solo aparece si hay un total válido.
    private var summary: String {
        guard let progress else { return "Sin progreso registrado" }
        guard let total = progress.totalPages, let fraction = progress.fractionRead else {
            return "Página \(progress.currentPage)"
        }
        let percent = Int((fraction * 100).rounded())
        return "Página \(progress.currentPage) de \(total) · \(percent) %"
    }
}
#endif
