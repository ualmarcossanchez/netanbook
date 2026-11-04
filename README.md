# netanbook

Desarrollo de nuestra bookapp para la asignatura de Líneas de Productos Software (Universidad de Almería).

**Netanbook** es tu biblioteca personal de bolsillo: en segundos sabes qué libros tienes, cuál estás leyendo y cuáles quieres leer. Es una familia de productos: un Core común (libro con título, autor y estado de lectura) al que se añaden features opcionales.

**Equipo:** Marcos Sánchez García · Javier Zúñiga Carmona · Maria Camila Soto Zapata · Daniel Arevalo Almendros

## Estado actual: sesión 3

- Modelo de características: Core, F1–F5 y una feature original por integrante.
- Listado de libros con MVVM: `Book` y `ReadingStatus` (Model), `BookListView` (View) y `BookListViewModel` (ViewModel).
- Bocetos de los modelos de datos de cada feature.

Documento de la sesión: [docs/sesion-3/Sesion3_Netanbook_MVVM.md](docs/sesion-3/Sesion3_Netanbook_MVVM.md)

## Estructura

```
Sources/Netanbook/
├── Application/       @main y configuración del producto
├── Core/
│   ├── Models/        Book, ReadingStatus
│   ├── ViewModels/    BookListViewModel
│   └── Views/         BookListView, BookRowView
├── Features/          F1–F5 y features originales (una carpeta por feature)
└── Infrastructure/    Persistence y Plugins
```

## Ejecutar

La interfaz usa [SwiftCrossUI](https://github.com/moreSwift/swift-cross-ui), así que funciona en Windows, macOS y Linux.

```sh
swift run
```

- **Windows:** toolchain de Swift y Visual Studio 2022 con las herramientas de C++ y el SDK de Windows.
- **macOS:** macOS 14 o posterior.
- **Linux:** GTK 4 (`sudo apt install libgtk-4-dev`).

Extensiones recomendadas de Visual Studio Code: **Swift** (`swiftlang.swift-vscode`) y **PlantUML** (`jebbs.plantuml`).
