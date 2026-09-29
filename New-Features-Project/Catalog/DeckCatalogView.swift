import SwiftUI

/// Modo baralho: as demos empilhadas como cartas. Arraste para o lado para
/// passar (a carta voa e volta para o fundo do monte), toque para abrir.
struct DeckCatalogView: View {
    let items: [DemoMetadata]
    let namespace: Namespace.ID
    let open: (String) -> Void

    @State private var top = 0
    @State private var drag: CGSize = .zero
    @State private var swipes = 0

    private let visibleDepth = 3
    private let threshold: CGFloat = 110

    var body: some View {
        Group {
            if items.isEmpty {
                ContentUnavailableView(
                    "Nenhuma demo ainda",
                    systemImage: "rectangle.on.rectangle.slash",
                    description: Text("Registre uma demo em DemoRegistry.all. Veja Demos/README.md.")
                )
            } else {
                VStack(spacing: 28) {
                    deck
                    controls
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .navigationSubtitle(items.isEmpty ? "" : "\(position + 1) de \(items.count)")
        .sensoryFeedback(.impact(weight: .light), trigger: swipes)
    }

    // MARK: - Estado

    /// Índice da carta do topo, sempre dentro de `items` (o monte é circular).
    private var position: Int {
        (top % items.count + items.count) % items.count
    }

    private func item(atDepth depth: Int) -> DemoMetadata {
        items[(position + depth) % items.count]
    }

    /// Joga a carta do topo para fora e, quando ela sai, a manda para o fundo.
    private func flick(direction: CGFloat) {
        guard items.count > 1 else {
            withAnimation(Motion.bouncy) { drag = .zero }
            return
        }
        swipes += 1
        withAnimation(.easeIn(duration: 0.22)) {
            drag = CGSize(width: direction * 520, height: drag.height + 40)
        } completion: {
            withAnimation(Motion.state) {
                drag = .zero
                top += 1
            }
        }
    }

    private func step(_ delta: Int) {
        swipes += 1
        withAnimation(Motion.state) { top += delta }
    }

    // MARK: - Monte

    private var deck: some View {
        // Identidade pela demo, não pela profundidade: quando o monte gira, cada
        // carta anima até a nova posição em vez de ser recriada.
        let stack = (0..<min(visibleDepth, items.count)).map { (depth: $0, item: item(atDepth: $0)) }

        return ZStack {
            ForEach(stack.reversed(), id: \.item.id) { entry in
                let item = entry.item
                let depth = entry.depth
                let isTop = depth == 0

                card(item)
                    .matchedTransitionSource(id: item.id, in: namespace)
                    .scaleEffect(1 - CGFloat(depth) * 0.06)
                    .offset(y: CGFloat(depth) * -22)
                    .offset(isTop ? drag : .zero)
                    .rotationEffect(.degrees(isTop ? Double(drag.width / 18) : 0))
                    .zIndex(Double(visibleDepth - depth))
                    .allowsHitTesting(isTop)
                    .onTapGesture { open(item.id) }
                    .gesture(
                        DragGesture()
                            .onChanged { drag = $0.translation }
                            .onEnded { value in
                                if abs(value.translation.width) > threshold {
                                    flick(direction: value.translation.width > 0 ? 1 : -1)
                                } else {
                                    withAnimation(Motion.bouncy) { drag = .zero }
                                }
                            }
                    )
            }
        }
        .frame(maxHeight: .infinity)
    }

    private func card(_ item: DemoMetadata) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(item.category.title, systemImage: item.category.symbol)
                .font(.caption.weight(.bold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.white.opacity(0.2), in: Capsule())

            Spacer()

            Image(systemName: item.symbol)
                .font(.system(size: 120, weight: .semibold))
                .frame(maxWidth: .infinity)
                .shadow(color: .black.opacity(0.2), radius: 16, y: 8)

            Spacer()

            Text(item.title).font(.title.bold())
            Text(item.summary)
                .font(.subheadline)
                .opacity(0.85)
                .lineLimit(2)
            HStack(spacing: 6) {
                ForEach(item.apis.prefix(2), id: \.self) { api in
                    Text(api)
                        .font(.caption2.monospaced())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.black.opacity(0.18), in: Capsule())
                }
            }
        }
        .foregroundStyle(.white)
        .padding(22)
        .frame(maxWidth: .infinity)
        .frame(height: 440)
        .background(item.category.tint.gradient, in: .rect(cornerRadius: 34, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 18, y: 10)
        .contentShape(.rect(cornerRadius: 34))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Toque para abrir. Deslize para o lado para passar.")
    }

    // MARK: - Controles

    private var controls: some View {
        HStack(spacing: 16) {
            Button("Anterior", systemImage: "arrow.uturn.backward") { step(-1) }
                .labelStyle(.iconOnly)
                .buttonStyle(.glass)
                .controlSize(.large)

            Button {
                open(item(atDepth: 0).id)
            } label: {
                Text("Abrir demo")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
            .tint(item(atDepth: 0).category.tint)

            Button("Próxima", systemImage: "arrow.uturn.forward") { step(1) }
                .labelStyle(.iconOnly)
                .buttonStyle(.glass)
                .controlSize(.large)
        }
    }
}
