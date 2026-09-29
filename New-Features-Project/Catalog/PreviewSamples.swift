#if DEBUG
import Foundation

/// Demos fictícias só para previews: mostram como o catálogo se comporta cheio.
/// Não existem no registry, então abrir uma delas cai em "Demo não encontrada".
extension DemoMetadata {
    static let previewSamples: [DemoMetadata] = [
        sample("transitions.hero-zoom", "Zoom de herói", "Card que se expande até virar a tela",
               "arrow.up.left.and.arrow.down.right", .transitions, ["navigationTransition", "matchedTransitionSource"]),
        sample("glass.morph-toolbar", "Toolbar que se funde", "Botões de vidro que se unem e se separam",
               "circle.hexagongrid.fill", .glass, ["GlassEffectContainer", "glassEffectID"]),
        sample("scroll.parallax", "Parallax em cartões", "Profundidade atrelada à posição do scroll",
               "square.stack.3d.down.right.fill", .scroll, ["scrollTransition", "visualEffect"]),
        sample("gestures.rubber-band", "Elástico", "Arraste com resistência e retorno de mola",
               "hand.draw.fill", .gestures, ["DragGesture", "spring"]),
        sample("shaders.ripple", "Onda no toque", "Distorção que se propaga a partir do dedo",
               "drop.fill", .shaders, ["layerEffect", "ShaderLibrary"]),
        sample("text.typewriter", "Máquina de escrever", "Texto revelado caractere a caractere",
               "character.cursor.ibeam", .text, ["TextRenderer"]),
        sample("charts.live-pulse", "Pulso ao vivo", "Gráfico que respira com dados em tempo real",
               "waveform.path.ecg", .charts, ["Chart", "LineMark"]),
        sample("intelligence.summary", "Resumo on-device", "Texto gerado pelo modelo local do sistema",
               "sparkles", .intelligence, ["LanguageModelSession", "@Generable"]),
    ]

    private static func sample(
        _ id: String, _ title: String, _ summary: String,
        _ symbol: String, _ category: DemoCategory, _ apis: [String]
    ) -> DemoMetadata {
        DemoMetadata(
            id: id, title: title, summary: summary,
            explanation: "Demo fictícia, só para preview.",
            symbol: symbol, category: category, apis: apis, tags: ["exemplo"]
        )
    }
}
#endif
