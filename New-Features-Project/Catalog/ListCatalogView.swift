import SwiftUI

/// Modo lista: tudo agrupado por categoria, com busca e filtro. É o caminho
/// rápido quando você já sabe o que procura.
struct ListCatalogView: View {
    let items: [DemoMetadata]
    let namespace: Namespace.ID
    @Binding var isSearching: Bool

    @State private var query = ""
    @State private var selectedCategory: DemoCategory?

    private var results: [DemoMetadata] {
        items.filter { item in
            (selectedCategory == nil || item.category == selectedCategory) && item.matches(query)
        }
    }

    /// Categorias que têm demo, na ordem canônica de `DemoCategory`.
    private var categories: [DemoCategory] {
        let present = Set(items.map(\.category))
        return DemoCategory.allCases.filter(present.contains)
    }

    /// Agrupa os resultados preservando a ordem canônica de `DemoCategory`.
    private var grouped: [(category: DemoCategory, items: [DemoMetadata])] {
        let buckets = Dictionary(grouping: results, by: \.category)
        return DemoCategory.allCases.compactMap { category in
            guard let items = buckets[category], !items.isEmpty else { return nil }
            return (category, items)
        }
    }

    var body: some View {
        List {
            Section {
                categoryFilter
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }

            if results.isEmpty {
                emptyState
            } else {
                ForEach(grouped, id: \.category) { group in
                    Section(group.category.title) {
                        ForEach(group.items) { metadata in
                            NavigationLink(value: metadata.id) {
                                DemoCard(metadata: metadata)
                                    .matchedTransitionSource(id: metadata.id, in: namespace)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationSubtitle("\(results.count) de \(items.count) demos")
        .searchable(text: $query, isPresented: $isSearching, prompt: "Buscar demo, API ou tag")
    }

    // MARK: - Filtro por categoria

    private var categoryFilter: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                chip(title: "Tudo", tint: .secondary, isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(categories) { category in
                    chip(
                        title: category.title,
                        tint: category.tint,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = (selectedCategory == category) ? nil : category
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
        }
        .scrollIndicators(.hidden)
        .contentMargins(.horizontal, 0, for: .scrollContent)
    }

    private func chip(
        title: String,
        tint: Color,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? tint.opacity(0.22) : Color.secondary.opacity(0.12),
                            in: Capsule())
                .foregroundStyle(isSelected ? tint : .secondary)
        }
        .buttonStyle(.plain)
        .motion(Motion.tap, value: isSelected)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    // MARK: - Vazio

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Nada encontrado", systemImage: "magnifyingglass")
        } description: {
            Text(items.isEmpty
                 ? "Nenhuma demo registrada ainda. Veja Demos/README.md."
                 : "Nenhuma demo casa com esses filtros.")
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }
}
