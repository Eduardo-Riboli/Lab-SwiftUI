import SwiftUI

/// Curvas e durações nomeadas.
///
/// Num laboratório de animação a comparação entre técnicas só é justa se o
/// "tempo base" for o mesmo. Use estas em vez de literais soltos.
enum Motion {
    /// Resposta a toque. Curta e com mola leve.
    static let tap = Animation.spring(response: 0.3, dampingFraction: 0.7)
    /// Mudança de estado visível na tela.
    static let state = Animation.spring(response: 0.45, dampingFraction: 0.8)
    /// Entrada/saída de conteúdo.
    static let enter = Animation.smooth(duration: 0.5)
    /// Mola solta, com overshoot perceptível.
    static let bouncy = Animation.bouncy(duration: 0.6, extraBounce: 0.2)
}

extension View {
    /// Como `.animation(_:value:)`, mas respeitando **Reduce Motion**.
    ///
    /// Com movimento reduzido ligado, usa `reduced` (por padrão `nil`, que corta
    /// a animação sem congelar a mudança de estado). Toda demo deve passar por
    /// aqui em vez de chamar `.animation` direto.
    func motion<V: Equatable>(
        _ animation: Animation,
        value: V,
        reduced: Animation? = nil
    ) -> some View {
        modifier(MotionModifier(animation: animation, reduced: reduced, value: value))
    }
}

private struct MotionModifier<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let animation: Animation
    let reduced: Animation?
    let value: V

    func body(content: Content) -> some View {
        content.animation(reduceMotion ? reduced : animation, value: value)
    }
}
