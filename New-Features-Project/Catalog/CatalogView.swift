import SwiftUI

/// Como o catálogo é exibido. Persistido, então o app abre no último modo usado.
enum CatalogLayout: String, CaseIterable {
    /// Cartas empilhadas, para explorar.
    case deck
    /// Lista com busca e filtro, para achar algo rápido.
    case list

    var title: String {
        switch self {
        case .deck: "Baralho"
        case .list: "Lista"
        }
    }

    var symbol: String {
        switch self {
        case .deck: "rectangle.on.rectangle.angled"
        case .list: "list.bullet"
        }
    }

    var other: CatalogLayout { self == .deck ? .list : .deck }
}

/// A porta de entrada: o mesmo registry em dois modos, trocados pela toolbar.
/// Não conhece nenhuma demo específica — só `DemoMetadata`.
struct CatalogView: View {
    var items: [DemoMetadata] = DemoRegistry.metadata

    @Environment(AppRouter.self) private var router
    @AppStorage("catalog.layout") private var layout: CatalogLayout = .deck
    @State private var isSearching = false
    /// Compartilhado pelos dois modos: a demo sempre abre com zoom a partir
    /// do card (ou da linha) que foi tocado.
    @Namespace private var zoom

    var body: some View {
        Group {
            switch layout {
            case .deck:
                DeckCatalogView(items: items, namespace: zoom) { id in
                    router.path.append(id)
                }
                .transition(.blurReplace)
            case .list:
                ListCatalogView(items: items, namespace: zoom, isSearching: $isSearching)
                    .transition(.blurReplace)
            }
        }
        .motion(Motion.state, value: layout)
        .navigationTitle("Laboratório")
        .toolbar { toolbar }
        .navigationDestination(for: String.self) { id in
            destination(for: id)
                .navigationTransition(.zoom(sourceID: id, in: zoom))
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        // No baralho, a lupa é o atalho: pula para a lista já buscando.
        if layout == .deck {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Buscar", systemImage: "magnifyingglass") {
                    layout = .list
                    isSearching = true
                }
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                layout = layout.other
            } label: {
                Label("Ver como \(layout.other.title)", systemImage: layout.other.symbol)
                    .contentTransition(.symbolEffect(.replace))
            }
        }
    }

    // MARK: - Destino

    @ViewBuilder
    private func destination(for id: String) -> some View {
        if let demo = DemoRegistry.demo(id: id) {
            DemoHostView(demo: demo)
        } else {
            ContentUnavailableView(
                "Demo não encontrada",
                systemImage: "questionmark.folder",
                description: Text("Nenhuma demo registrada com o id “\(id)”.")
            )
        }
    }
}

#Preview("Demos reais") {
    RootView()
        .environment(AppRouter())
}

#if DEBUG
#Preview("Catálogo cheio") {
    @Previewable @State var router = AppRouter()

    NavigationStack(path: $router.path) {
        CatalogView(items: DemoRegistry.metadata + DemoMetadata.previewSamples)
    }
    .environment(router)
}
#endif
