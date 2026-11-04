# Sesión 3 · Modelo de características y listado de libros con MVVM

**Universidad de Almería · Grado en Ingeniería Informática · Líneas de Productos de Software**
**Producto:** Netanbook (nuestra BookApp)
**Equipo:** Marcos Sánchez García · Javier Zúñiga Carmona · Maria Camila Soto Zapata · Daniel Arevalo Almendros

---

## 1. Qué entregamos

| Comprobación | Evidencia | Dónde está |
|---|---|---|
| Núcleo claro | `Book` con `id`, `title`, `author` y `status`; `ReadingStatus` con tres valores | `Sources/Netanbook/Core/Models/` |
| Variabilidad correcta | Core obligatorio; F1–F5 y las originales opcionales e independientes, sin grupo OR | Apartado 2 y `diagramas/modelo-caracteristicas.puml` |
| MVVM implementada | El listado separa Model (`Book`, `ReadingStatus`), View (`BookListView`, `BookRowView`) y ViewModel (`BookListViewModel`) | `Sources/Netanbook/Core/` |
| Entregable | Este documento, tres diagramas PlantUML y el código Swift en Git | `docs/sesion-3/` y `Sources/` |

> Las imágenes de los diagramas se generan a partir de los `.puml` del repositorio con el servidor de PlantUML. En Visual Studio Code se pueden ver con la extensión PlantUML (`Alt+D`).

---

## 2. Modelo de características

![Modelo de características](https://www.plantuml.com/plantuml/proxy?cache=no&fmt=svg&src=https://raw.githubusercontent.com/ualmarcossanchez/netanbook/main/docs/sesion-3/diagramas/modelo-caracteristicas.puml)

Fuente: [`diagramas/modelo-caracteristicas.puml`](diagramas/modelo-caracteristicas.puml)

- **Netanbook** es la raíz. Su único hijo obligatorio es el **Core**.
- El **Core** agrupa todo lo que comparte la familia: el **libro** (identificador, título obligatorio, autor opcional y estado de lectura), la **gestión de la biblioteca** (añadir, listar y consultar, editar, cambiar estado y eliminar) y la **persistencia local**, cuya tecnología queda pendiente de decidir.
- Las **cinco features comunes** (F1 Progreso, F2 Notas y citas, F3 Categorías, F4 Valoraciones y reseñas, F5 Estadísticas) y las **features originales** cuelgan de la raíz como **opcionales e independientes**.
- **No hay grupo OR**: un producto sin ninguna feature variable es válido (variante **Base**, solo Core).
- **No hay restricciones `requires` ni `excludes`**. El porcentaje de F1 usa el total de páginas, que es un dato de la propia F1. F5 se calcula solo con el Core y no necesita F1.
- El **autor** aparece como atributo del libro, no como feature.
- No hemos copiado el XOR JSON / Core Data de TaskApp: la persistencia es obligatoria, pero su tecnología aún no está fijada.

**Variantes que admite el modelo**

| Variante | Selección |
|---|---|
| Base | Solo Core |
| Común | Core + F1–F5 |
| Personalizada | Core + cualquier subconjunto de las features variables |
| Completa | Core + F1–F5 + O1–O4 |

> **Somos cuatro integrantes**, así que el modelo tiene **cuatro features originales** (O1–O4), una por persona. El enunciado habla de cinco porque supone grupos de cinco.

---

## 3. Listado de libros con MVVM

### 3.1 Model

**Estado de lectura** (`Core/Models/ReadingStatus.swift`). Tiene tres valores. `CaseIterable` permite recorrerlos y el `rawValue` es el texto legible.

```swift
enum ReadingStatus: String, CaseIterable, Sendable {
    case pending = "Pendiente"
    case reading = "Leyendo"
    case finished = "Terminado"

    var displayName: String { rawValue }
}
```

**Libro** (`Core/Models/Book.swift`). Es `Identifiable` con un `id` estable (`let`). El título es obligatorio, el autor puede faltar y un libro nuevo empieza como pendiente.

```swift
struct Book: Identifiable, Equatable, Sendable {
    let id: UUID
    var title: String
    var author: String?
    var status: ReadingStatus

    init(id: UUID = UUID(), title: String, author: String? = nil,
         status: ReadingStatus = .pending) { … }

    static func isValidTitle(_ title: String) -> Bool { … }
}
```

El inicializador quita los espacios sobrantes del título y guarda como `nil` un autor en blanco. `isValidTitle(_:)` recoge la regla de que el título no puede estar vacío. El ViewModel la usará al añadir y editar libros en la sesión 4.

### 3.2 ViewModel

`Core/ViewModels/BookListViewModel.swift` es una clase `@Observable` que guarda la colección con tres libros de ejemplo. Cuando la colección cambie, la vista se volverá a dibujar.

```swift
@Observable
final class BookListViewModel {
    private(set) var books: [Book]

    init(books: [Book] = BookListViewModel.sampleBooks) { self.books = books }

    func books(with status: ReadingStatus) -> [Book] {
        books.filter { $0.status == status }
    }
}
```

`private(set)` hace que solo el ViewModel pueda modificar la colección. El parámetro `books` del inicializador permitirá cargar después los libros guardados en la persistencia.

### 3.3 View

- `BookListView` crea el ViewModel con `@State` y recorre `ReadingStatus.allCases` para mostrar un grupo por estado. Es el listado de nuestro MVP (M2): los libros separados en Pendiente, Leyendo y Terminado.
- `BookSectionView` muestra el nombre del estado y sus libros, o «Sin libros» si no hay ninguno.
- `BookRowView` muestra el título y el autor, o «Autor desconocido» si falta.

La vista no guarda libros: solo lee del ViewModel.

### 3.4 Interfaz: SwiftCrossUI

La demostración de TaskApp de la sesión 3 usa SwiftUI, que solo existe en los sistemas de Apple. Parte del equipo trabaja en Windows, así que la interfaz usa **SwiftCrossUI 0.10**, como el repositorio de ejemplo `uallps/TaskApp-SwiftCrossUI`. Funciona en Windows (WinUI), macOS (AppKit) y Linux (GTK 4).

Model y ViewModel son Swift puro: solo importan `Foundation` y `Observation`. Únicamente las vistas y la aplicación importan SwiftCrossUI. Así, en la sesión 4 se podrá separar la interfaz en versiones SwiftUI y SwiftCrossUI sin tocar el Core.

---

## 4. Boceto de los modelos de las features

Son solo declaraciones, sin funcionalidad. **Ninguna feature añade campos a `Book`**: cada una guarda sus propios datos y apunta al libro con `bookID`.

| Feature | Tipos | Campos principales | Relación con `Book` |
|---|---|---|---|
| F1 Progreso | `ReadingProgress` | `bookID`, `totalPages: Int?`, `currentPage` | 1 libro → 0..1 progreso |
| F2 Notas y citas | `BookNote`, `NoteKind` | `bookID`, `kind` (Nota/Cita), `text`, `page: Int?`, `createdAt` | 1 libro → 0..N anotaciones |
| F3 Categorías | `BookCategory`, `BookCategoryAssignment` | `name`; asignación `bookID` + `categoryID` | N libros ↔ M categorías |
| F4 Valoraciones y reseñas | `BookReview` | `bookID`, `rating` (1–5), `text: String?` | 1 libro → 0..1 valoración |
| F5 Estadísticas | `LibraryStatistics` | `totalBooks`, `pendingCount`, `readingCount`, `finishedCount` | Sin datos propios: se calcula a partir de `[Book]` |
| O1 Préstamos | `BookLoan` | `bookID`, `borrowerName`, `loanDate`, `dueDate?`, `returnedDate?` | 1 libro → 0..N préstamos |
| O2 Objetivo anual | `ReadingGoal` | `year`, `targetBooks`, `completedBookIDs` | Cuenta libros terminados del Core |
| O3 Temporizador de lectura | `ReadingSession` | `bookID`, `startDate`, `endDate?` | 1 libro → 0..N sesiones |
| O4 Importar y exportar CSV | `CSVFormat`, `CSVBookRecord` | `title`, `author?`, `statusText` | Cada fila equivale a un `Book` del Core |

![Diagrama de clases](https://www.plantuml.com/plantuml/proxy?cache=no&fmt=svg&src=https://raw.githubusercontent.com/ualmarcossanchez/netanbook/main/docs/sesion-3/diagramas/mvvm-clases.puml)

Fuente: [`diagramas/mvvm-clases.puml`](diagramas/mvvm-clases.puml)

---

## 5. Estructura del proyecto

```
netanbook/
├── Package.swift
├── docs/sesion-3/                      Documento y diagramas PlantUML
└── Sources/Netanbook/
    ├── Application/
    │   ├── NetanbookApp.swift          @main, abre BookListView
    │   └── AppConfig.swift             Catálogo de features y variantes (se usará en la sesión 4)
    ├── Core/
    │   ├── Models/                     Book, ReadingStatus
    │   ├── ViewModels/                 BookListViewModel
    │   └── Views/                      BookListView (+ BookSectionView), BookRowView
    ├── Features/
    │   ├── Progreso/                   F1 · ReadingProgress
    │   ├── NotasYCitas/                F2 · BookNote, NoteKind
    │   ├── Categorias/                 F3 · BookCategory, BookCategoryAssignment
    │   ├── ValoracionesYResenas/       F4 · BookReview
    │   ├── Estadisticas/               F5 · LibraryStatistics
    │   ├── Prestamos/                  O1 · BookLoan
    │   ├── ObjetivoAnual/              O2 · ReadingGoal
    │   ├── TemporizadorLectura/        O3 · ReadingSession
    │   └── ImportarExportar/           O4 · CSVFormat, CSVBookRecord
    └── Infrastructure/
        ├── Persistence/                BookStorage (protocolo; tecnología por decidir)
        └── Plugins/                    Vacío: se creará en sesiones posteriores
```

![Estructura del proyecto](https://www.plantuml.com/plantuml/proxy?cache=no&fmt=svg&src=https://raw.githubusercontent.com/ualmarcossanchez/netanbook/main/docs/sesion-3/diagramas/estructura-proyecto.puml)

Fuente: [`diagramas/estructura-proyecto.puml`](diagramas/estructura-proyecto.puml)

Las dependencias van en un solo sentido: Application → Views → ViewModels → Models. Features e Infrastructure dependen de los Models del Core, pero el Core no depende de ellas. Hemos comprobado que ningún archivo de `Core`, `Application` ni `Infrastructure` usa tipos de `Features`.

---

## 6. Responsabilidades

| Responsabilidad | Componente |
|---|---|
| Guardar la colección de libros y ofrecer el listado (agrupado por estado) | **`BookListViewModel`** |
| Modificar el estado de los libros (y, en la sesión 4, añadirlos y eliminarlos) | **`BookListViewModel`**, el único que modifica el Model. Buscará el libro por `id`, no por su posición en la lista |
| Dibujar el listado y comunicar las acciones del usuario | `BookListView`, `BookSectionView` y `BookRowView` |
| Datos y reglas del dominio | `Book` y `ReadingStatus` |

---

## 7. Comprobación del diseño

**¿Qué campos del libro son obligatorios y cuáles opcionales? ¿Por qué?**

- **Obligatorios:**
  - `id`: identifica el libro de forma estable. Lo usan la lista para distinguir las filas y las features para asociar sus datos (`bookID`). No cambia aunque se edite el libro.
  - `title`: sin título no se reconoce el libro. Además no puede estar vacío (`isValidTitle`).
  - `status`: todo libro está siempre en uno de los tres estados. Como tiene valor por defecto (`.pending`), el usuario no tiene que elegirlo al darlo de alta.
- **Opcional:**
  - `author` (`String?`): un libro concreto puede no tener autor conocido (por ejemplo, el *Lazarillo de Tormes*) o el usuario puede no saberlo. Exigirlo haría más lento el alta. En la investigación de mercado vimos que Goodreads recibe críticas precisamente por ser lenta en tareas simples.

**¿Quién guarda la colección de libros: la vista o el ViewModel? ¿Qué ocurre si más adelante hay que añadir o borrar libros?**

La guarda el **ViewModel**. La vista solo tiene el ViewModel en un `@State` y lee `viewModel.books(with:)`. Para añadir o borrar libros (sesión 4) bastará con añadir métodos al ViewModel (`addBook`, `deleteBook(id:)`, `changeStatus(id:to:)`). Como es `@Observable`, la vista se actualizará sola sin cambiar su estructura. Si la colección estuviera en la vista, la validación, las operaciones y la futura persistencia quedarían mezcladas con la interfaz. Tampoco podrían compartirla otras pantallas, como las estadísticas de F5.

**¿Podría el Core existir sin las notas, las categorías o las valoraciones? ¿Dónde se guardan entonces esos datos?**

Sí. `Book` no tiene ningún campo de notas, categorías ni valoraciones, y el Core no usa ningún tipo de `Features`. Esos datos se guardan en los tipos de cada feature (`BookNote`, `BookCategory` y `BookCategoryAssignment`, `BookReview`), que apuntan al libro con `bookID`. Cada feature tendrá su propia colección en su ViewModel o almacenamiento. En un producto sin esa feature, esos datos simplemente no existen y el Core funciona igual. Cuando se elimine un libro, cada feature activa deberá borrar sus datos asociados. Lo resolveremos al implementar las operaciones.

**¿Qué diferencia hay entre que el autor sea opcional y que F1 sea una característica opcional del producto?**

- **El autor opcional** se decide en el **nivel de los datos**. Todos los productos de la familia tienen el campo `author`, pero un libro concreto puede no tenerlo. Lo decide el usuario, libro a libro, mientras usa la app, y se expresa con un opcional de Swift (`String?`).
- **F1 opcional** se decide en el **nivel del producto** (variabilidad de la línea de productos): si ese producto incluye o no la funcionalidad de progreso, con sus tipos, pantallas y datos. Se decide al configurar el producto (feature flag, compilación condicional o plugin, según veamos en las próximas sesiones), no libro a libro. En la variante Base no existe ni siquiera el concepto de páginas.

Un opcional de Swift no sustituye a la variabilidad de la línea de productos: dentro de F1, `totalPages` también es `Int?`, porque un libro puede no tener ese dato aunque el producto incluya F1.

---

## 8. Reparto de features

Somos cuatro y hay cinco features comunes, así que a una persona le tocan dos. Le damos F5 a quien lleva F1, porque F5 es la más pequeña: no tiene datos propios y se calcula a partir del Core.

| Integrante | Features comunes | Feature original |
|---|---|---|
| Marcos Sánchez García | F1 Progreso · F5 Estadísticas | O1 Préstamos |
| Javier Zúñiga Carmona | F2 Notas y citas | O2 Objetivo anual de lectura |
| Maria Camila Soto Zapata | F3 Categorías | O3 Temporizador de lectura |
| Daniel Arevalo Almendros | F4 Valoraciones y reseñas | O4 Importar y exportar CSV |

Las originales salen de las funcionalidades opcionales que identificamos en la sesión 2. Son distintas entre sí y no repiten F1–F5. Cada una se integra con el Core a través de `Book.id` y se puede excluir de cualquier variante.

---

## 9. Cómo ejecutar

```sh
swift run
```

- **Windows:** toolchain de Swift con Visual Studio 2022 (herramientas de C++ y SDK de Windows) y el modo de desarrollador activado. La primera compilación descarga SwiftCrossUI y sus dependencias, así que tarda unos minutos.
- **macOS:** Xcode o el toolchain de Swift (macOS 14 o posterior).
- **Linux:** toolchain de Swift y GTK 4 (`sudo apt install libgtk-4-dev`).

**Extensiones de Visual Studio Code:** *Swift* (`swiftlang.swift-vscode`) y *PlantUML* (`jebbs.plantuml`) para ver los diagramas.

---

## 10. Siguiente paso (sesión 4)

Añadir al `BookListViewModel` las operaciones de cambiar el estado, añadir y eliminar libros, y activar el primer feature flag a partir de `AppConfig`.
