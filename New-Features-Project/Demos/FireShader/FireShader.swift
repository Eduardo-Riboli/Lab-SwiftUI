import SwiftUI

// MARK: - Registro

extension Demo {
    static let fireShader = Demo.make(
        id: "shaders.fire",
        title: "Fogo procedural",
        summary: "Shader Metal desenhando chamas pixel a pixel, em tempo real",
        explanation: """
            Não há imagem nem sistema de partículas aqui. Um shader Metal marcado \
            com `[[ stitchable ]]` recebe a posição de cada pixel mais o tempo, e \
            devolve a cor — chamas inteiras calculadas do zero pela GPU.

            O desenho tem três partes: ruído de valor somado em oitavas (fBm) para \
            dar a textura irregular, um deslocamento vertical no tempo para a chama \
            subir, e um gradiente que apaga o fogo em direção ao topo.

            É também a demo de referência do encanamento: se ela anima, o arquivo \
            `.metal` está sendo compilado e `ShaderLibrary` está resolvendo a função \
            pelo nome. Copie esta pasta para começar qualquer demo de shader.
            """,
        symbol: "flame.fill",
        category: .shaders,
        apis: ["colorEffect", "ShaderLibrary", "TimelineView", "stitchable"],
        tags: ["metal", "fogo", "fbm", "ruído", "gpu"]
    ) { FireShaderView() }
}

// MARK: - Demo

struct FireShaderView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Instante em que a demo apareceu. O shader recebe o tempo decorrido a
    /// partir daqui, e não o relógio absoluto, para começar sempre do mesmo ponto.
    @State private var start = Date.now

    var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { context in
            let elapsed = context.date.timeIntervalSince(start)

            GeometryReader { proxy in
                let size = proxy.size

                Rectangle()
                    .fill(.white)
                    .colorEffect(
                        ShaderLibrary.fire(
                            .float2(size),
                            .float(reduceMotion ? 0 : Float(elapsed))
                        )
                    )
            }
        }
        .background(.black)
        .ignoresSafeArea()
        .overlay(alignment: .bottom) { caption }
    }

    private var caption: some View {
        Text(reduceMotion
             ? "Movimento reduzido: quadro estático"
             : "fbm(5 oitavas) · deslocamento vertical no tempo")
            .font(.caption.monospaced())
            .foregroundStyle(.white.opacity(0.7))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.black.opacity(0.35), in: Capsule())
            .padding(.bottom, 28)
    }
}

#Preview {
    NavigationStack {
        DemoHostView(demo: .fireShader)
    }
}
