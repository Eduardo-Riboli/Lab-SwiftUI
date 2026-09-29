import SwiftUI

/// A única fonte de verdade do catálogo.
///
/// **Para adicionar uma demo nova, acrescente uma linha em `all`.** Nada mais.
/// A pasta em `Demos/` entra no target sozinha (o projeto usa
/// `PBXFileSystemSynchronizedRootGroup`), então nunca há `.pbxproj` para editar.
@MainActor
enum DemoRegistry {

    // MARK: - Registro

    static let all: [Demo] = [
        .phaseAnimatorHeart,
        .fireShader,
    ]

    // MARK: - Consultas

    static let metadata: [DemoMetadata] = all.map(\.metadata)

    private static let byID: [String: Demo] = Dictionary(
        uniqueKeysWithValues: all.map { ($0.id, $0) }
    )

    static func demo(id: String) -> Demo? { byID[id] }

    static func metadata(id: String) -> DemoMetadata? { byID[id]?.metadata }

    /// Categorias que realmente têm demo, na ordem de `DemoCategory.allCases`.
    /// O filtro da UI usa isto para não mostrar categoria vazia.
    static let populatedCategories: [DemoCategory] = {
        let present = Set(all.map(\.metadata.category))
        return DemoCategory.allCases.filter(present.contains)
    }()

    static func search(_ query: String, category: DemoCategory? = nil) -> [DemoMetadata] {
        metadata.filter { item in
            (category == nil || item.category == category) && item.matches(query)
        }
    }
}
