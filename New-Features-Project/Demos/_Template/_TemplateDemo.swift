import SwiftUI

// Copie esta pasta, renomeie tudo, e acrescente uma linha em DemoRegistry.all.
// Enquanto o nome começar com "_", esta demo fica de fora do catálogo — ela não está registrada.

// MARK: - Registro
extension Demo {
    static let templateDemo = Demo.make(
        // Convenção: "categoria.nome-curto". Isto é CONTRATO — depois de registrado, não mude (é a chave de navegação, deep link e Siri).
        id: "components.template",
        title: "Nome da demo",
        summary: "Uma linha que aparece no card da lista",
        explanation: """
            O que essa coisa faz, e por que ela é interessante. Este texto é o \
            painel de info da demo — é o que transforma o app numa referência \
            consultável em vez de uma coleção de telas bonitas.

            Vale explicar o truque, não só o efeito.
            """,
        symbol: "sparkles",                 // qualquer SF Symbol
        category: .components,              // ver DemoCategory
        apis: ["PhaseAnimator"],            // vira chip e entra na busca
        tags: ["exemplo"]
    ) { TemplateDemoView() }
}

// MARK: - Demo
struct TemplateDemoView: View {
    var body: some View {
        ContentUnavailableView(
            "Sua demo aqui",
            systemImage: "hammer",
            description: Text("Substitua este corpo pelo efeito que você quer mostrar.")
        )
    }
}

#Preview {
    NavigationStack {
        DemoHostView(demo: .templateDemo)
    }
}
