import SwiftUI

/// O chrome que toda demo ganha de graça: título, painel "o que isso faz" e
/// botão de reiniciar.
///
/// A identidade do conteúdo é presa a `runID`, que só muda quando você toca em
/// reiniciar. Mudanças de layout (rotação, Split View) **não** recriam a demo,
/// então o estado da animação sobrevive.
struct DemoHostView: View {
    let demo: Demo

    @State private var runID = UUID()
    @State private var showsInfo = false

    var body: some View {
        demo.content()
            .id(runID)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle(demo.metadata.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Reiniciar", systemImage: "arrow.clockwise") {
                        runID = UUID()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("O que isso faz", systemImage: "info.circle") {
                        showsInfo = true
                    }
                }
            }
            .sheet(isPresented: $showsInfo) {
                DemoInfoSheet(metadata: demo.metadata)
            }
    }
}

/// O painel que explica a demo. É o que transforma o app de "coleção de telas"
/// em referência consultável.
private struct DemoInfoSheet: View {
    let metadata: DemoMetadata

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header

                    section("O que isso faz") {
                        Text(metadata.explanation.markdown)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }

                    if !metadata.apis.isEmpty {
                        section("APIs demonstradas") {
                            FlowChips(items: metadata.apis, tint: metadata.category.tint, monospaced: true)
                        }
                    }

                    if !metadata.tags.isEmpty {
                        section("Tags") {
                            FlowChips(items: metadata.tags, tint: .secondary, monospaced: false)
                        }
                    }

                    section("Identificador") {
                        Text(metadata.id)
                            .font(.footnote.monospaced())
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle(metadata.title)
            .navigationBarTitleDisplayMode(.inline)
            .presentationDetents([.medium, .large])
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(metadata.category.tint.gradient)
                .frame(width: 54, height: 54)
                .overlay {
                    Image(systemName: metadata.symbol)
                        .font(.title2)
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(metadata.summary)
                    .font(.headline)
                Label(metadata.category.title, systemImage: metadata.category.symbol)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            content()
        }
    }
}

/// Chips que quebram linha sozinhos. Usa o layout nativo de fluxo do SwiftUI.
private struct FlowChips: View {
    let items: [String]
    let tint: Color
    let monospaced: Bool

    var body: some View {
        ViewThatFits(in: .horizontal) {
            row
            FlowLayout(spacing: 8) { chips }
        }
    }

    private var row: some View {
        HStack(spacing: 8) { chips }
    }

    private var chips: some View {
        ForEach(items, id: \.self) { item in
            Text(item)
                .font(monospaced ? .caption.monospaced() : .caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(tint.opacity(0.15), in: Capsule())
                .foregroundStyle(tint)
        }
    }
}

/// Layout de fluxo mínimo: preenche a linha e quebra quando não cabe.
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var rows: CGFloat = 1, x: CGFloat = 0, rowHeight: CGFloat = 0, totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + spacing + size.width > maxWidth {
                totalHeight += rowHeight + spacing
                rows += 1
                x = size.width
                rowHeight = size.height
            } else {
                x += (x > 0 ? spacing : 0) + size.width
                rowHeight = max(rowHeight, size.height)
            }
        }
        totalHeight += rowHeight
        return CGSize(width: maxWidth == .infinity ? x : maxWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX, x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}


private extension String {
    /// Renderiza markdown inline na explicação — `crases` viram código
    /// monoespaçado. Volta ao texto cru se o markdown não fizer parse.
    var markdown: AttributedString {
        (try? AttributedString(
            markdown: self,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )) ?? AttributedString(self)
    }
}
