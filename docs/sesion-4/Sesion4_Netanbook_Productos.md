# Sesión 4 · Dos productos del mismo código y F1 Progreso

**Universidad de Almería · Grado en Ingeniería Informática · Líneas de Productos de Software**
**Producto:** Netanbook (nuestra BookApp)
**Equipo:** Marcos Sánchez García · Javier Zúñiga Carmona · Maria Camila Soto Zapata · Daniel Arevalo Almendros

---

## 1. Qué entregamos

| Criterio | Evidencia |
|---|---|
| Productos | Proyecto de Xcode con los targets y schemes `Netanbook` y `Netanbook Progreso`. En Linux y Windows, `swift run Netanbook` y `swift run --traits Progreso Netanbook`. |
| Un solo código | Los dos productos compilan la carpeta `Netanbook/`: en Xcode es una carpeta sincronizada que pertenece a los dos targets y en `Package.swift` es el `path` del único ejecutable. No hay ficheros copiados. |
| Feature flags | `AppConfig` (`@Observable`) declara los flags de F1–F5, todos desactivados. F1 existe como flag (`showProgress`) y como variable de compilación (`#if Progreso`). |
| MVVM | `BookRowView` recibe el libro, el flag y las acciones como closures y no conoce ningún ViewModel. Las operaciones están en `BookListViewModel` y en `ReadingProgressViewModel`. |
| Trabajo común | Partimos del listado de libros de la sesión 3 (`Book`, `ReadingStatus`, `BookListViewModel`, `BookListView`) sobre la misma base que el ejemplo del curso. |
| `Package.resolved` | En la raíz del repositorio, generado al compilar con `Package.swift`. |
| Capturas | Apartado 7: producto base y Netanbook Progreso con el progreso visible. |

La integración continua (`.github/workflows/ci.yml`) compila en cada push los dos schemes de Xcode en macOS y los dos productos de `Package.swift` en Linux y Windows.

---

## 2. Base común: Xcode y `Package.swift` sobre la misma carpeta

El ejemplo del curso para esta sesión ([TaskApp-2026](https://github.com/uallps/TaskApp-2026)) usa un proyecto de Xcode en macOS y un `Package.swift` en Linux y Windows que compilan la **misma carpeta**. En Linux y Windows, el módulo `Compat/SwiftUI` reexporta [SwiftOpenUI](https://github.com/uallps/SwiftOpenUI), así que todas las vistas escriben `import SwiftUI`.

En la sesión 3 teníamos el código en `Sources/Netanbook/` con SwiftCrossUI. Lo hemos movido a `Netanbook/` con `git mv`, para conservar el historial, y las vistas usan ahora SwiftUI. El modelo (`Book`, `ReadingStatus`) y el ViewModel del listado son los de la sesión 3, con las operaciones nuevas.

```
Netanbook.xcodeproj/   targets Netanbook y Netanbook Progreso
Package.swift          trait Progreso
Compat/SwiftUI/        SwiftUI de Linux y Windows (SwiftOpenUI)
Netanbook/
├── Application/       NetanbookApp, AppConfig (flags F1–F5) y Product (nombre del producto)
├── Core/              Models, ViewModels y Views del listado
└── Features/Progreso/ F1: Models, ViewModels y Views, dentro de #if Progreso
```

---

## 3. Operaciones del listado en el ViewModel

`BookListViewModel` sigue siendo el dueño de la colección (`private(set) var books`) y el único que la modifica:

```swift
func changeStatus(id: UUID, to status: ReadingStatus)   // cambiar el estado de lectura
func advanceStatus(id: UUID)                             // Pendiente → Leyendo → Terminado → Pendiente
func addSampleBook()                                     // añadir un libro de ejemplo
```

Los libros se buscan por `id` y no por posición, porque la lista está agrupada por estado y las posiciones cambian. Al cambiar de estado, el libro pasa a la sección correspondiente.

---

## 4. La fila en una vista propia

`Core/Views/BookRowView.swift` recibe el libro, el flag de F1 y las acciones como closures:

```swift
struct BookRowView: View {
    let book: Book
    let showProgress: Bool
#if Progreso
    let progress: ReadingProgress?
#endif
    let changeStatus: () -> Void
#if Progreso
    let advanceProgress: () -> Void
#endif
    ...
}
```

El botón de estado ejecuta `changeStatus`. Es `BookListView` quien decide qué hace: `{ viewModel.advanceStatus(id: book.id) }`.

---

## 5. Flags de F1–F5

`Application/AppConfig.swift` es configuración de la aplicación, no datos de los libros:

```swift
@Observable
final class AppConfig {
    var showProgress = false     // F1 Progreso
    var showNotes = false        // F2 Notas y citas
    var showCategories = false   // F3 Categorías
    var showReviews = false      // F4 Valoraciones y reseñas
    var showStatistics = false   // F5 Estadísticas
}
```

Todos empiezan desactivados. En Netanbook Progreso, el botón «Progreso: Sí/No» cambia `showProgress` con la app en marcha y las filas se redibujan sin recompilar.

---

## 6. F1 Progreso como componente independiente

| Fichero | Contenido |
|---|---|
| `Features/Progreso/Models/ReadingProgress.swift` | `ReadingProgress`: libro (`bookID`), total de páginas (`Int?`) y página actual; porcentaje solo si hay un total válido |
| `Features/Progreso/ViewModels/ReadingProgressViewModel.swift` | `@Observable`: progreso de cada libro (`[UUID: ReadingProgress]`) y `advance(bookID:by:)` |
| `Features/Progreso/Views/ReadingProgressView.swift` | Barra de progreso, «Página 250 de 662 · 38 %» y botón «+10 páginas» |

Los tres ficheros están dentro de `#if Progreso`. Ni `Book` ni `BookListViewModel` saben que F1 existe. El Core solo ofrece tres puntos de conexión, también dentro de `#if Progreso`:

1. `BookListView` guarda `ReadingProgressViewModel` en un `@State` propio.
2. `BookListView` muestra el botón del flag.
3. `BookRowView` recibe el progreso y la acción de avanzar, y muestra `ReadingProgressView` solo si `showProgress` está activo.

**Sin la variable `Progreso`, el código de F1 no se compila.** El script `scripts/comprobar-f1.ps1` compila los dos productos y busca el tipo `ReadingProgressViewModel` en cada ejecutable. La CI de Linux hace la misma comprobación con `strings`.

| Ejecutable | Apariciones de `ReadingProgressViewModel` |
|---|---|
| Netanbook (base) | {{F1_BASE}} |
| Netanbook Progreso | {{F1_PROGRESO}} |

![Dos productos del mismo código](https://www.plantuml.com/plantuml/proxy?cache=no&fmt=svg&src=https://raw.githubusercontent.com/ualmarcossanchez/netanbook/main/docs/sesion-4/diagramas/dos-productos.puml)

Fuente: [`diagramas/dos-productos.puml`](diagramas/dos-productos.puml)

---

## 7. Los dos productos

### Xcode: un target por producto

| | Netanbook | Netanbook Progreso |
|---|---|---|
| Target y scheme | `Netanbook` | `Netanbook Progreso` (duplicado del anterior) |
| Active Compilation Conditions | `DEBUG` en Debug | `Progreso` en Debug y en Release |
| Bundle Identifier | `es.ual.Netanbook` | `es.ual.Netanbook.Progreso` |
| Ficheros | carpeta sincronizada `Netanbook/` | la misma carpeta |

```shell
xcodebuild -project Netanbook.xcodeproj -scheme "Netanbook" build
xcodebuild -project Netanbook.xcodeproj -scheme "Netanbook Progreso" build
```

### `Package.swift`: un trait por característica

```swift
traits: [
    .trait(name: "Progreso", description: "F1 Progreso: páginas leídas de cada libro"),
],
```

```shell
swift run Netanbook                      # producto base
swift run --traits Progreso Netanbook    # Netanbook Progreso
```

Las opciones de `swift run` van antes del nombre del ejecutable. Si se escriben después, se pasan a la app como argumentos y no activan nada.

### Capturas (Windows)

| Netanbook (base) | Netanbook Progreso, con el flag de F1 activado |
|---|---|
| ![Netanbook base](capturas/netanbook-base.png) | ![Netanbook Progreso](capturas/netanbook-progreso.png) |

---

## 8. Qué comparten, qué es distinto y cómo se separan el Core y F1

Los dos productos comparten toda la carpeta `Netanbook/`:

- el Core: `Book`, `ReadingStatus`, `BookListViewModel` con sus operaciones, `BookListView` y `BookRowView`;
- la configuración `AppConfig`, con los flags de F1–F5;
- el punto de entrada de la aplicación.

Lo único distinto es la variable de compilación `Progreso`. La activan el target «Netanbook Progreso» de Xcode y el trait `Progreso` de `Package.swift`. Con ella se compilan los ficheros de `Features/Progreso`, el botón del flag y la parte de la fila que muestra el progreso. Además, ese producto tiene su propio Bundle Identifier y su propio nombre.

El Core y F1 se separan de dos formas:

- **Datos y lógica propios.** F1 guarda sus datos (`ReadingProgress`, asociado al libro por `bookID`) en su propio ViewModel (`ReadingProgressViewModel`). No toca `Book` ni `BookListViewModel`.
- **Compilación aparte.** Todo el código de F1 está dentro de `#if Progreso`, así que el producto base no lo contiene.

Por encima de esto, el flag `showProgress` decide con la app en marcha si el progreso se muestra.

---

## 9. Comprobación del diseño

**¿En qué se parece un target (o un trait) a un feature flag y en qué se diferencia?**

**En qué se parecen:** los dos deciden qué características ofrece el producto, son configuración y no datos, y mantienen un único código fuente.

**En qué se diferencian:** en cuándo se decide cada uno.

- **El target o el trait se decide antes de compilar.** Si la característica no está seleccionada, su código no existe en el ejecutable. Para cambiarlo hay que recompilar, y el resultado es otro producto, con su propio Bundle Identifier en Xcode.
- **El flag se decide con la app en marcha.** El código está en el ejecutable y el valor de `AppConfig` solo decide si se muestra. Al cambiarlo, la vista se actualiza sin recompilar.

Son dos niveles: el target o trait decide si F1 **existe** y el flag decide si se **muestra**.

**Con F1 desactivada, ¿siguen funcionando la biblioteca y los datos del libro? ¿Y con F1 sin compilar?**

Sí, en los dos casos.

- **Con el flag desactivado:** el listado, el cambio de estado y el alta funcionan igual. Los datos de progreso siguen en `ReadingProgressViewModel` y vuelven a aparecer al activar el flag.
- **Sin compilar F1 (producto base):** el Core es exactamente el mismo, porque `Book` no tiene campos de progreso y `BookListViewModel` no hace referencia a F1. Lo único que falta es el código de F1, que no está en el ejecutable (apartado 6).

**¿Dónde viven los datos de progreso y por qué no en el libro?**

Viven en `ReadingProgress`, dentro de `ReadingProgressViewModel.progressByBook`, indexados por `Book.id`, en la carpeta `Features/Progreso`.

No están en `Book` porque el libro es el Core que comparten todos los productos. Si `totalPages` y `currentPage` estuvieran en `Book`:

- el producto base llevaría datos de una característica que no tiene;
- el Core dependería de F1 y no se podría dejar F1 sin compilar sin tocar el modelo;
- cada característica nueva haría crecer `Book`.

Con la asociación por `bookID`, F1 se añade o se quita sin cambiar el Core.

**¿Por qué la fila recibe una closure en lugar del ViewModel?**

Para que la fila no dependa de ningún ViewModel. Así:

- se puede reutilizar en otras pantallas y con otros datos;
- es la lista la que decide qué hace cada acción: cambiar el estado en `BookListViewModel` o avanzar páginas en `ReadingProgressViewModel`.

Si recibiera el ViewModel, la fila quedaría acoplada a `BookListViewModel` y, con F1, también a `ReadingProgressViewModel`. Además, podría modificar el modelo directamente, cuando en MVVM eso es tarea del ViewModel y la vista solo comunica las acciones.

**¿Qué pasaría si copiarais la carpeta para hacer el segundo producto en vez de duplicar el target?**

Tendríamos dos copias del código, `Netanbook/` y una copia para Netanbook Progreso, que se irían separando. Cada corrección o cambio del Core habría que hacerlo dos veces, y es fácil olvidarse de una. Eso es «copiar y modificar», no una línea de productos.

Al duplicar el target, los dos productos usan la misma carpeta sincronizada. Solo cambian los ajustes de compilación (*Active Compilation Conditions* y *Bundle Identifier*), así que cada cambio del Core llega a los dos productos a la vez.

---

## 10. Cómo reproducirlo

- **macOS:** abrir `Netanbook.xcodeproj`, elegir el scheme `Netanbook` o `Netanbook Progreso` y pulsar ▶.
- **Windows y Linux:**
  - `swift run Netanbook`
  - `swift run --traits Progreso Netanbook`
- **Comprobación de F1 (Windows):** `powershell -ExecutionPolicy Bypass -File scripts/comprobar-f1.ps1`
- **Capturas (Windows):** con la app abierta, `powershell -ExecutionPolicy Bypass -File scripts/capturar-ventana.ps1 -Nombre <nombre>`
