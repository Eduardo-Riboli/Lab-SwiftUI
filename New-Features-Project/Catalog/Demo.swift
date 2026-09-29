import SwiftUI

/// Uma demo do catálogo: o metadado mais como construir a tela.
///
/// Não é `Sendable` — carrega um closure `@MainActor` de `View`. É exatamente por
/// isso que `DemoMetadata` existe separado: o que precisa cruzar fronteiras de
/// concorrência é o metadado, nunca isto.
struct Demo: Identifiable {
    let metadata: DemoMetadata
    let content: @MainActor () -> AnyView

    var id: String { metadata.id }
}

extension Demo {
    /// Ponto de entrada para registrar uma demo. O genérico sobre `V` evita que
    /// você escreva `AnyView` na mão a cada demo nova.
    static func make<V: View>(
        id: String,
        title: String,
        summary: String,
        explanation: String,
        symbol: String,
        category: DemoCategory,
        apis: [String] = [],
        tags: [String] = [],
        @ViewBuilder content: @escaping @MainActor () -> V
    ) -> Demo {
        Demo(
            metadata: DemoMetadata(
                id: id,
                title: title,
                summary: summary,
                explanation: explanation,
                symbol: symbol,
                category: category,
                apis: apis,
                tags: tags
            ),
            content: { AnyView(content()) }
        )
    }
}
