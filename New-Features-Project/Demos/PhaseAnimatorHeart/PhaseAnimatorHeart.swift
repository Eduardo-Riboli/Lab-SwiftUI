import SwiftUI

// MARK: - Registro

extension Demo {
    static let phaseAnimatorHeart = Demo.make(
        id: "components.phase-heart",
        title: "Curtir multi-fase",
        summary: "Um toque, três fases coreografadas com PhaseAnimator",
        explanation: """
            `PhaseAnimator` percorre uma sequência de fases a cada vez que o \
            `trigger` muda, e deixa você escolher uma animação diferente para \
            cada trecho. É a forma declarativa de coreografar "encolhe, estoura, \
            assenta" sem encadear `withAnimation` com `DispatchQueue.asyncAfter`.

            Repare que as três fases têm curvas distintas: a compressão é rápida \
            e seca, o estouro é elástico, e a volta é suave.
            """,
        symbol: "heart.fill",
        category: .components,
        apis: ["PhaseAnimator", "symbolEffect", "sensoryFeedback"],
        tags: ["botão", "curtir", "coreografia", "mola"]
    ) { PhaseAnimatorHeartView() }
}

// MARK: - Demo

struct PhaseAnimatorHeartView: View {
    /// As fases pelas quais o coração passa a cada toque.
    private enum Beat: CaseIterable {
        case rest, squash, burst

        var scale: CGFloat {
            switch self {
            case .rest:   1.0
            case .squash: 0.72
            case .burst:  1.35
            }
        }

        var rotation: Angle {
            switch self {
            case .rest:   .zero
            case .squash: .degrees(-8)
            case .burst:  .degrees(6)
            }
        }

        /// Cada trecho da coreografia tem sua própria curva.
        var animation: Animation {
            switch self {
            case .rest:   .spring(response: 0.45, dampingFraction: 0.6)
            case .squash: .easeOut(duration: 0.12)
            case .burst:  .spring(response: 0.3, dampingFraction: 0.35)
            }
        }
    }

    @State private var taps = 0
    @State private var isLiked = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            PhaseAnimator(Beat.allCases, trigger: taps) { beat in
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .font(.system(size: 96))
                    .foregroundStyle(isLiked ? AnyShapeStyle(Color.pink.gradient)
                                             : AnyShapeStyle(Color.secondary))
                    .scaleEffect(beat.scale)
                    .rotationEffect(beat.rotation)
            } animation: { beat in
                beat.animation
            }
            .contentTransition(.symbolEffect(.replace))

            Text(isLiked ? "Curtido" : "Toque no coração")
                .font(.headline)
                .foregroundStyle(.secondary)
                .contentTransition(.numericText())

            Spacer()

            Button {
                isLiked.toggle()
                taps += 1
            } label: {
                Text(isLiked ? "Descurtir" : "Curtir")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(.pink)
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: taps)
    }
}

#Preview {
    NavigationStack {
        DemoHostView(demo: .phaseAnimatorHeart)
    }
}
