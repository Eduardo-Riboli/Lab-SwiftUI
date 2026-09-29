import Foundation

/// Tudo que se sabe sobre uma demo **sem construir a tela dela**.
///
/// É dado puro e `Sendable` de propósito: além do card e da busca, este é o tipo
/// que a `EntityQuery` da Siri e a indexação no Spotlight vão consumir numa fase
/// futura — e ambas rodam fora do main actor.
struct DemoMetadata: Identifiable, Hashable, Sendable {
    /// Contrato estável. É a chave de navegação, de deep link e (depois) da Siri.
    /// Uma vez publicado, **não muda**. Convenção: `categoria.nome`.
    let id: String
    let title: String
    /// Uma linha. Aparece no card da lista.
    let summary: String
    /// O que essa coisa faz e por que é interessante. Aparece no painel de info.
    let explanation: String
    let symbol: String
    let category: DemoCategory
    /// APIs demonstradas, ex. `["colorEffect", "ShaderLibrary"]`.
    /// Viram chips na tela de info e entram na busca.
    let apis: [String]
    let tags: [String]

    /// Texto achatado contra o qual a busca roda. Inclui APIs e tags, então
    /// procurar por `colorEffect` acha a demo mesmo sem estar no título.
    var searchHaystack: String {
        ([title, summary, category.title] + apis + tags)
            .joined(separator: " ")
            .lowercased()
    }

    func matches(_ query: String) -> Bool {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return true }
        return searchHaystack.contains(q)
    }
}
