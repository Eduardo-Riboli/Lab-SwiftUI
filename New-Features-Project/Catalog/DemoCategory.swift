import SwiftUI

/// Os pilares do laboratório. Adicionar um caso novo é seguro: a UI deriva
/// tudo daqui, então uma categoria nova aparece no filtro automaticamente.
enum DemoCategory: String, CaseIterable, Identifiable, Sendable {
    case shaders
    case transitions
    case scroll
    case gestures
    case text
    case components
    case charts
    case glass
    case intelligence
    case platform
    case adaptive

    var id: String { rawValue }

    var title: String {
        switch self {
        case .shaders:      "Shaders"
        case .transitions:  "Transições"
        case .scroll:       "Scroll"
        case .gestures:     "Gestos"
        case .text:         "Texto"
        case .components:   "Componentes"
        case .charts:       "Gráficos"
        case .glass:        "Liquid Glass"
        case .intelligence: "Inteligência"
        case .platform:     "Plataforma"
        case .adaptive:     "Adaptativo"
        }
    }

    var symbol: String {
        switch self {
        case .shaders:      "wand.and.stars"
        case .transitions:  "rectangle.2.swap"
        case .scroll:       "arrow.up.and.down.text.horizontal"
        case .gestures:     "hand.draw"
        case .text:         "textformat"
        case .components:   "square.on.circle"
        case .charts:       "chart.xyaxis.line"
        case .glass:        "circle.hexagongrid"
        case .intelligence: "sparkles"
        case .platform:     "app.badge"
        case .adaptive:     "rectangle.expand.vertical"
        }
    }

    var tint: Color {
        switch self {
        case .shaders:      .orange
        case .transitions:  .purple
        case .scroll:       .teal
        case .gestures:     .pink
        case .text:         .indigo
        case .components:   .blue
        case .charts:       .mint
        case .glass:        .cyan
        case .intelligence: .yellow
        case .platform:     .green
        case .adaptive:     .brown
        }
    }
}
