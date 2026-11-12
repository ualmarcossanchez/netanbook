# netanbook

Desarrollo de nuestra bookapp para la asignatura de Líneas de Productos Software (Universidad de Almería).

**Netanbook** es tu biblioteca personal de bolsillo: en segundos sabes qué libros tienes, cuál estás leyendo y cuáles quieres leer. Es una familia de productos: un Core común (libro con título, autor y estado de lectura) al que se añaden features opcionales.

**Equipo:** Marcos Sánchez García · Javier Zúñiga Carmona · Maria Camila Soto Zapata · Daniel Arevalo Almendros

## Productos

El mismo código de la carpeta `Netanbook/` da lugar a dos productos (desde la sesión 4):

| Producto | Contenido | Xcode (Mac) | Linux y Windows |
|---|---|---|---|
| Netanbook | Solo el Core | scheme `Netanbook` | `swift run Netanbook` |
| Netanbook Progreso | Core + F1 Progreso | scheme `Netanbook Progreso` | `swift run --traits Progreso Netanbook` |

- La variable de compilación `Progreso` decide si el código de F1 **existe** en el producto: en Xcode es el target «Netanbook Progreso» (*Active Compilation Conditions*); en `Package.swift` es el trait `Progreso`.
- El flag `showProgress` de `AppConfig` decide si F1 se **muestra** con la app en marcha. Los flags de F1–F5 empiezan desactivados.
- Las opciones de `swift run` van antes del nombre del ejecutable: `swift run --traits Progreso Netanbook`.

## Cómo se ejecuta en cada sistema

| Sistema | Cómo se ejecuta | Interfaz |
|---|---|---|
| macOS | Abrir `Netanbook.xcodeproj`, elegir el scheme y pulsar ▶ | SwiftUI de Apple |
| Windows | `swift run Netanbook` (Swift **6.3.x**, Visual Studio 2022 con C++ y el SDK de Windows, y el modo de desarrollador activado) | [SwiftOpenUI](https://github.com/uallps/SwiftOpenUI) con Win32 |
| Linux | `swift run Netanbook` (necesita `libgtk-4-dev` y `libfontconfig-dev`) | SwiftOpenUI con GTK 4 |

En Linux y Windows, `Package.swift` añade un módulo llamado `SwiftUI` (carpeta `Compat/`) que reexporta SwiftOpenUI, así que `import SwiftUI` funciona sin cambiar el código. Es la misma base que el ejemplo del curso, [TaskApp-2026](https://github.com/uallps/TaskApp-2026).

> En Windows, SwiftOpenUI todavía no compila con Swift 6.4. Hay que usar Swift 6.3.x, como la CI del curso.

## Estructura

```
Netanbook.xcodeproj/        Proyecto de Xcode: targets Netanbook y Netanbook Progreso
Package.swift               Paquete para Linux y Windows, con el trait Progreso
Compat/SwiftUI/             Módulo SwiftUI de Linux y Windows (reexporta SwiftOpenUI)
Netanbook/                  Código común a los dos productos
├── Application/            @main con la barra lateral, AppConfig (flags F1–F5) y Theme
├── Core/
│   ├── Models/             Book, ReadingStatus, libros de ejemplo
│   ├── ViewModels/         BookListViewModel (listado, cambiar estado, añadir)
│   └── Views/              BookListView, BookRowView (fila con closures) y BookDetailView
├── Features/
│   ├── Progreso/           F1: Models, ViewModels, Views y Persistence, todo dentro de #if Progreso
│   ├── Settings/           Pantalla de Ajustes
│   └── ...                 Bocetos de F2–F5 y de las features originales
└── Infrastructure/         Persistence (BookStorageProvider: JSON y Mock) y Plugins
Tests/NetanbookTests/       Pruebas del ViewModel con MockBookStorageProvider (swift test)
scripts/                    Comprobación de F1 y prueba de interfaz con capturas (Windows)
docs/                       Documento de cada sesión
```

## Documentación

- [Sesión 3: modelo de características y listado con MVVM](docs/sesion-3/Sesion3_Netanbook_MVVM.md)
- [Sesión 4: dos productos y F1 Progreso](docs/sesion-4/Sesion4_Netanbook_Productos.md)
- [Sesión 5: navegación, paso de datos y Git Flow](docs/sesion-5/Sesion5_Netanbook_Navegacion.md)
- [Sesión 6: persistencia, ajustes compartidos y tema](docs/sesion-6/Sesion6_Netanbook_Persistencia.md)

La integración continua (`.github/workflows/ci.yml`) compila los dos schemes de Xcode en macOS y los dos productos de `Package.swift` en Linux y Windows. También comprueba que el código de F1 solo está en Netanbook Progreso y, en Windows, hace las capturas de los dos productos.
