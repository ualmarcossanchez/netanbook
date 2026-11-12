# Sesión 6 · Persistencia, ajustes compartidos y tema

**Universidad de Almería · Grado en Ingeniería Informática · Líneas de Productos de Software**
**Producto:** Netanbook (nuestra BookApp)
**Equipo:** Marcos Sánchez García · Javier Zúñiga Carmona · Maria Camila Soto Zapata · Daniel Arevalo Almendros

---

## 1. Qué entregamos

| Criterio | Evidencia |
|---|---|
| Persistencia | Los libros se guardan en `netanbook-libros.json` (carpeta Documentos) y los ajustes en `UserDefaults`. Se conservan al cerrar y abrir la app (apartado 7). |
| Protocolo | `BookListViewModel` solo conoce `BookStorageProvider`. `JSONBookStorageProvider` y `MockBookStorageProvider` son intercambiables: se eligen en el `init`. |
| Entorno | `NetanbookApp` crea una sola `AppConfig` y la pone en el entorno. El listado y Ajustes la leen con `@Environment`. |
| Tema | `Application/Theme.swift`: color de acento, estilo `bookCaption()` y color de cada estado de lectura. Los usan la fila, el detalle y la vista de progreso. |
| Mock | `Tests/NetanbookTests/BookListViewModelTests.swift` (5 pruebas, `swift test`) y la vista previa de `BookListView` usan `MockBookStorageProvider`. |
| Capturas | Apartado 7: Ajustes con el flag apagado y el listado tras reiniciar. |

---

## 2. Modelo `Codable`

`Book` y `ReadingStatus` son ahora `Codable`. No ha hecho falta nada más:

- `ReadingStatus` es un `enum` con `String` de valor bruto: en el JSON se guarda ese texto.
- `Book.id` sigue siendo `let`. Como se asigna en el `init` (no tiene un valor por defecto en la declaración), al leer el JSON se conserva el `id` guardado. Es importante: F1 asocia el progreso al libro por ese `id`.

---

## 3. Almacenamiento detrás de un protocolo

```swift
protocol BookStorageProvider {
    func loadBooks() async throws -> [Book]
    func saveBooks(_ books: [Book]) async throws
}
```

| Implementación | Dónde guarda | Uso |
|---|---|---|
| `JSONBookStorageProvider` | `netanbook-libros.json` en Documentos. Crea la carpeta si no existe (hace falta en Linux). | La app, en los tres sistemas. |
| `MockBookStorageProvider` | En memoria. | Pruebas y vistas previas. |

Los tres ficheros están en `Netanbook/Infrastructure/Persistence/` y sustituyen al boceto `BookStorage.swift` de la sesión 3.

### El ViewModel carga y guarda

```swift
@Observable
final class BookListViewModel {
    private(set) var books: [Book] = Book.samples {
        didSet { if !isLoading { save() } }
    }

    @ObservationIgnored private let storageProvider: BookStorageProvider

    init(storageProvider: BookStorageProvider = JSONBookStorageProvider()) {
        self.storageProvider = storageProvider
        loadTask = Task { await load() }
    }
}
```

- **Guardar:** el `didSet` de `books` guarda cada cambio, venga de donde venga: cambiar el estado en la fila, añadir, borrar o editar en el detalle. Ningún método tiene que acordarse de guardar.
- **Cargar:** al crearse, el ViewModel pide los libros al almacenamiento. Si todavía no hay nada guardado, se quedan los libros de ejemplo. Lo que se acaba de leer no se vuelve a guardar.
- **Orden:** cada guardado espera al anterior, así que lo último que se escribe es siempre el último cambio.

### F1 guarda sus propios datos

El progreso no está en `Book`, así que tampoco está en `netanbook-libros.json`. F1 tiene su propio almacenamiento, `ReadingProgressStorage` (`Features/Progreso/Persistence/`, dentro de `#if Progreso`), que guarda en `netanbook-progreso.json`. El Core y `BookStorageProvider` no saben que existe, y en el producto base ese código no se compila.

---

## 4. Configuración: `UserDefaults` y entorno

`AppConfig` mantiene los cinco flags (F1–F5), todos desactivados la primera vez. Cada flag se guarda al cambiar:

```swift
var showProgress: Bool {
    didSet { store(showProgress, forKey: "showProgress") }
}

init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
    showProgress = defaults.object(forKey: "showProgress") as? Bool ?? false
    // … igual para F2–F5
}
```

Se lee con `object(forKey:)` para distinguir «apagado» de «nunca guardado». En Linux y Windows, `synchronize()` fuerza la escritura en disco.

La app crea **una sola** configuración y la comparte por el entorno:

```swift
@main
struct NetanbookApp: App {
    @State private var config = AppConfig()
    @State private var selection: String? = "libros"

    var body: some Scene {
        WindowGroup(Product.name) {
            NavigationSplitView {
                List(selection: $selection) {
                    NavigationLink(value: "libros") { Label("Libros", systemImage: "books.vertical") }
                    NavigationLink(value: "ajustes") { Label("Ajustes", systemImage: "gearshape") }
                }
            } detail: {
                // BookListView() o SettingsView(), según la selección
            }
            .environment(config)
        }
    }
}
```

- `BookListView` la lee con `@Environment(AppConfig.self)`. Ya no crea la suya.
- `SettingsView` la lee igual y la edita con `@Bindable`.
- En iPhone, la barra lateral se sustituye por pestañas (`TabView`), como en el ejemplo del curso.

---

## 5. Pantalla de Ajustes

`Features/Settings/Views/SettingsView.swift`: un interruptor por característica común.

| Interruptor | Flag | Estado |
|---|---|---|
| Mostrar el progreso de lectura | `showProgress` (F1) | Solo aparece en Netanbook Progreso (`#if Progreso`). Muestra u oculta el progreso en el listado. |
| Notas y citas | `showNotes` (F2) | Se guarda, pero F2 aún no está implementada. |
| Categorías | `showCategories` (F3) | Igual. |
| Valoraciones y reseñas | `showReviews` (F4) | Igual. |
| Estadísticas | `showStatistics` (F5) | Igual. |

Los cuatro últimos están en una sección titulada «Próximas características (sin implementar)», para no dar a entender que hacen algo. El botón «Progreso: Sí/No» que había en la barra del listado desaparece: el flag se cambia ahora en Ajustes.

---

## 6. Tema con extensiones

`Application/Theme.swift` reúne el aspecto de la app:

```swift
extension Color {
    static let bookAccent = Color(red: 0.45, green: 0.27, blue: 0.13)
}

struct CaptionStyle: ViewModifier { … }          // .font(.caption) + color

extension View {
    func bookCaption(color: Color = .secondary) -> some View { modifier(CaptionStyle(color: color)) }
}

extension ReadingStatus {
    var color: Color { … }                        // pendiente: gris · leyendo: acento · terminado: verde
}
```

| Dónde se usa | Qué usa |
|---|---|
| `BookRowView` | `book.status.color` en el icono de estado y `.bookCaption()` en el autor. |
| `BookDetailView` | `.bookCaption()` en el autor. |
| `ReadingProgressView` (F1) | `.bookCaption()` en el texto del progreso. |

Antes, `.font(.caption).foregroundColor(.secondary)` estaba repetido en tres vistas.

---

## 7. Comprobación

### Pruebas con `MockBookStorageProvider`

`swift test` (lo ejecuta la CI en Linux). Las pruebas crean el ViewModel con el almacenamiento en memoria:

| Prueba | Qué comprueba |
|---|---|
| `testCargaLosLibrosDelAlmacenamiento` | Al crearse, el ViewModel muestra los libros del almacenamiento. |
| `testCadaCambioSeGuarda` | Cambiar el estado y añadir un libro llegan al almacenamiento. |
| `testEditarEnElDetalleYBorrarTambienSeGuardan` | `updateBook` y `removeBook` también se guardan. |
| `testUnTituloVacioNoSeGuarda` | Un título en blanco no sustituye al anterior. |
| `testElLibroSeCodificaYDecodificaEnJSON` | `Book` conserva `id`, título y estado al pasar por JSON. |

### Prueba de interfaz y capturas (Windows, Netanbook Progreso)

`scripts/probar-interfaz.ps1` hace esto en la CI:

1. Borra los datos guardados y arranca la app.
2. Edita el título de «Lazarillo de Tormes» en el detalle.
3. Activa «Mostrar el progreso de lectura» en Ajustes y comprueba que el listado lo muestra.
4. Cierra y abre la app: el título editado y el progreso siguen ahí.
5. Apaga el flag en Ajustes, cierra y abre la app: el listado ya no muestra el progreso.

| Ajustes con el flag de F1 apagado | Listado tras reiniciar la app |
|---|---|
| ![Ajustes con el flag apagado](capturas/progreso-5-ajustes-flag-apagado.png) | ![Listado tras reiniciar](capturas/progreso-6-listado-tras-reiniciar.png) |

Antes de apagarlo, con el flag encendido y tras un reinicio:

| Listado con el progreso (flag encendido) | El mismo listado tras reiniciar |
|---|---|
| ![Listado con progreso](capturas/progreso-3-listado-con-progreso.png) | ![Tras reiniciar](capturas/progreso-4-tras-reiniciar.png) |

En el producto base, Ajustes no tiene el interruptor de F1:

| Ajustes en el producto base | Listado tras reiniciar (título editado) |
|---|---|
| ![Ajustes base](capturas/base-3-ajustes.png) | ![Base tras reiniciar](capturas/base-4-tras-reiniciar.png) |

---

## 8. Preguntas de diseño

### ¿Qué cambiaría si los libros se guardaran en SwiftData? ¿Y si solo cambiara el nombre del fichero?

- **SwiftData:** un fichero nuevo con otra implementación de `BookStorageProvider` y la línea que elige cuál se usa (el valor por defecto del `init` o quien crea el ViewModel). Como SwiftData solo existe en los sistemas de Apple, esa implementación iría dentro de `#if canImport(SwiftData)` y Linux y Windows seguirían con JSON. El ViewModel, las vistas y las pruebas no cambian.
- **Otro nombre de fichero:** solo el argumento `filename` de `JSONBookStorageProvider`. Nada más.

### ¿Por qué el almacenamiento es `@ObservationIgnored`?

Porque no es estado de la interfaz. `@Observable` vigila las propiedades para redibujar las vistas que las leen. El almacenamiento es una dependencia que no cambia y que ninguna vista muestra: observarlo no aporta nada. Lo mismo vale para `loadTask`, `isLoading` y `pendingSave`, que son detalles internos de la carga y el guardado.

### ¿Qué pasaría si la lista y Ajustes creasen cada uno su propia configuración?

Habría dos objetos distintos. Al cambiar un interruptor en Ajustes se modificaría (y guardaría) el de Ajustes, pero el listado seguiría leyendo el suyo y no cambiaría hasta reiniciar la app, cuando volviera a leer `UserDefaults`. Con una sola configuración en el entorno, el cambio se ve en el listado en cuanto se vuelve a él. La prueba de interfaz lo comprueba: activa el flag en Ajustes y, sin reiniciar, el listado muestra el progreso.

### ¿Dónde vive el color de cada estado de lectura, y por qué ahí?

En `Theme.swift`, en una extensión de `ReadingStatus`. El color es presentación, no dominio: `ReadingStatus.swift` (modelo) no importa SwiftUI y no debe saber de colores. Y al estar en el tema, y no en la fila, cualquier vista que muestre un estado usa el mismo color, y cambiarlo es tocar un solo fichero.

---

## 9. Cómo reproducirlo

- **macOS:** abrir `Netanbook.xcodeproj`, elegir el scheme y pulsar ▶. La vista previa de `BookListView` usa el almacenamiento en memoria.
- **Windows y Linux:** `swift run Netanbook` o `swift run --traits Progreso Netanbook`.
- **Pruebas:** `swift test`.
- **Prueba de interfaz (Windows):** `powershell -ExecutionPolicy Bypass -File scripts/probar-interfaz.ps1 -Variante Progreso`. Aviso: empieza borrando los libros y el progreso guardados.

Datos guardados: `Documentos/netanbook-libros.json` (libros), `Documentos/netanbook-progreso.json` (progreso de F1) y las preferencias de la app (`UserDefaults`). Para volver a los libros de ejemplo basta con borrar los dos ficheros JSON.
