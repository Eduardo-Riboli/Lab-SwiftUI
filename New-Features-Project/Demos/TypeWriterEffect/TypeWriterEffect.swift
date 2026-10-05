import SwiftUI
import CoreHaptics

// MARK: - Registro
extension Demo {
    static let typeWriterEffect = Demo.make(
        id: "text.typeWriterEffect",
        title: "TypeWriter Effect",
        summary: "Frases digitadas e apagadas letra por letra, em loop",
        explanation: """
            Um letreiro de máquina de escrever: cada frase é digitada caractere \
            por caractere, fica um instante na tela e é apagada antes da próxima \
            entrar, com um cursor piscando no final e o bloco sempre centralizado.

            O truque é que o texto inteiro já está no layout desde o início. Um \
            `TextRenderer` percorre os glifos do `Text.Layout` e decide a opacidade \
            de cada um a partir de um único `progress` de 0 a 1 — marcado com \
            `@Animatable`, ele é interpolado pelo SwiftUI quadro a quadro. Os \
            glifos ainda não digitados ocupam espaço, então um `visualEffect` \
            desloca o texto pela largura que falta, mantendo o cursor colado na \
            última letra visível e o conjunto centralizado.

            O ritmo de digitação vem de uma `CustomAnimation`: em vez de uma curva \
            contínua, ela divide o tempo em um passo por caractere e segura o valor \
            parado durante uma fração de cada passo (`PauseIntensity`), gerando os \
            "solavancos" de quem digita. O `TimelineView(.periodic)` troca de frase \
            a cada ciclo completo, o cursor pisca com `keyframeAnimator`, e o \
            `CoreHaptics` acompanha cada letra com um toque leve.
            """,
        symbol: "character.cursor.ibeam",
        category: .text,
        apis: ["TextRenderer", "Animatable", "CustomAnimation", "TimelineView", "visualEffect", "keyframeAnimator", "CoreHaptics"],
        tags: ["Texto", "Digitação", "Máquina de escrever", "Cursor", "Haptics"]
    ) { TypeWriterEffect() }
}

// MARK: - Demo
struct TypingTextConfig {
    var font: Font = .system(size: 25, weight: .bold)
    var typingIndicatorSize: CGSize = .init(width: 20, height: 2.5)
    
    var typingDuration: Double = 1
    var typingPauseIntensity: PauseIntensity = .full
    
    var dismissDuration: Double = 0.5
    var dismissPauseIntensity: PauseIntensity = .small
    
    var textWaitDelay: Double = 1.3
    var nextContentDelay: Double = 0.4
    
    var enableTextFading: Bool = false
    
    enum PauseIntensity: CGFloat {
        case small = 0.15
        case medium = 0.5
        case large = 0.85
        case full = 1.0
    }
}

struct TypeWriterTextView: View {
    var config: TypingTextConfig = .init()
    var texts: [String]
    
    @State private var startDate: Date?
    @State private var progress: CGFloat = 0
    @State private var hapticsManager: HapticsManager = .init()
    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        ZStack {
            if let startDate {
                // Using Timeline to auto type each text and loop!
                let duration = config.typingDuration + config.textWaitDelay + config.dismissDuration + config.nextContentDelay
                
                TimelineView(.periodic(from:  startDate, by: duration)) { ctx in
                    let index = Int((startDate.distance(to: ctx.date) / duration).rounded()) % texts.count
                    let text = texts[index]
                    
                    HStack(alignment: .bottom, spacing: 0) {
                        Text(text)
                            .font(config.font)
                            .textRenderer(TypingTextRenderer(fadeEffect: config.enableTextFading, progress: progress))
                            // Positioning as same as the indicator
                            .visualEffect { [progress] content, proxy in
                                let offset = proxy.size.width
                                
                                return content
                                    .offset(x: offset * (1 - progress))
                            }
                        
                        TypingIndication(size: config.typingIndicatorSize)
                    }
                    // Centering Content
                    .visualEffect { [config, progress] content, proxy in
                        let offset = (proxy.size.width - config.typingIndicatorSize.width) / 2
                        
                        return content
                            .offset(x: -offset * (1 - progress))
                    }
                    .onChange(of: text, initial: true) { oldValue, newValue in
                        animateText(for: newValue)
                    }
                }
            } else {
                // Placeholder Content
                HStack(alignment: .bottom, spacing: 0) {
                    Text(" ")
                        .font(config.font)
                        .frame(width: 0)
                    
                    TypingIndication(size: config.typingIndicatorSize)
                }
            }
        }
        .task {
            guard startDate == nil else { return }
            // initial delay
            try? await Task.sleep(for: .seconds(0.7))
            startDate = .now
        }
        // initial: true so the engine also starts when the view appears already active
        .onChange(of: scenePhase, initial: true) { oldValue, newValue in
            // only activating engine on active phase
            if newValue == .active {
                hapticsManager.prepareEngine()
            } else {
                hapticsManager.stopEngine()
            }
        }
    }
    
    private func animateText(for text: String) {
        Task {
            playHaptics(text: text, forDismiss: false)
            withAnimation(.typingAnimation(
                text: text,
                pause: config.typingPauseIntensity,
                duration: config.typingDuration
            )) {
                progress = 1
            }
            
            try? await Task.sleep(for: .seconds(config.typingDuration + config.textWaitDelay))
            
            playHaptics(text: text, forDismiss: true)
            withAnimation(.typingAnimation(
                text: text,
                pause: config.dismissPauseIntensity,
                duration: config.dismissDuration
            )) {
                progress = 0
            }
            
            // Dont need to manually wait for next delay as its already included in timeline duration!
        }
    }
    
    private func playHaptics(text: String, forDismiss: Bool) {
        guard scenePhase == .active else { return }
        do {
            let duration = forDismiss ? config.dismissDuration : config.typingDuration
            
            try hapticsManager.playHaptics(
                text: text,
                duration: duration,
                forDismiss: forDismiss
            )
        } catch {
            print(error.localizedDescription)
        }
    }
}

fileprivate struct TypingIndication: View {
    var size: CGSize
    var duration: CGFloat = 0.5
    var delay: CGFloat = 0.1
    
    var body: some View {
        Rectangle()
            .frame(width: size.width, height: size.height)
            .keyframeAnimator(initialValue: CGFloat.zero, repeating: true) { content, opacity in
                content
                    .opacity(opacity)
            } keyframes: { _ in
                MoveKeyframe(0)
                LinearKeyframe(1, duration: duration / 2)
                LinearKeyframe(1, duration: delay)
                LinearKeyframe(0, duration: duration / 2)
            }
    }
}

// Typing Text effect using text renderer
@Animatable
fileprivate struct TypingTextRenderer: TextRenderer {
    @AnimatableIgnored var fadeEffect: Bool
    var progress: CGFloat
    
    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        let slices = layout.flatMap { $0 }.flatMap { $0 }
        
        for (index, slice) in slices.enumerated() {
            var copy = ctx
            
            let rawProgress = progress * CGFloat(slices.count) - CGFloat(index)
            let progress = min(max(rawProgress, 0), 1)
            
            if fadeEffect {
                copy.opacity = progress
            } else {
                copy.opacity = progress.rounded()
            }
            
            copy.draw(slice)
        }
    }
}

struct TypeWriterEffect: View {
    var body: some View {
        VStack {
            let texts = [
                "Welcome to Apple",
                "Discover iPhone",
                "Explore Mac",
                "Experience Airpods",
                "Meet Apple Watch"
            ]
            
            TypeWriterTextView(config: .init(), texts: texts)
        }
    }
}

// MARK: - Custom Animation

// Custom Animation for the true typing effect with pauses
fileprivate struct TypingAnimation: CustomAnimation {
    var text: String
    var pauseIntensity: TypingTextConfig.PauseIntensity
    var duration: TimeInterval
    nonisolated func animate<V>(value: V, time: TimeInterval, context: inout AnimationContext<V>) -> V? where V : VectorArithmetic {
        let textCount = CGFloat(text.count)
        guard time <= duration else { return nil }
        
        let timeProgress = time / duration
        let index = floor(timeProgress * textCount)
        let currentProgress = (timeProgress * textCount) - index
        
        let pause = pauseIntensity.rawValue
        
        if currentProgress < pause {
            return value.scaled(by: index / textCount)
        }
        
        let newValue = (index + (currentProgress - pause) / (1 - pause)) / textCount
        return value.scaled(by: newValue)
    }
}

extension Animation {
    static func typingAnimation(text: String, pause: TypingTextConfig.PauseIntensity, duration: TimeInterval) -> Animation {
        Animation(TypingAnimation(text: text, pauseIntensity: pause, duration: duration))
    }
}

// MARK: - Haptics
@Observable
fileprivate class HapticsManager {
    var engine: CHHapticEngine?
    
    func prepareEngine() {
        #if !targetEnvironment(simulator)
        guard engine == nil else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print(error.localizedDescription)
        }
        #endif
    }
    
    func stopEngine() {
        #if !targetEnvironment(simulator)
        guard let engine else { return }
        // Clear right away so a quick return to .active can create a fresh engine
        self.engine = nil

        Task {
            do {
                try await engine.stop()
            } catch {
                print(error.localizedDescription)
            }
        }
        #endif
    }
    
    func playHaptics(text: String, duration: CGFloat, forDismiss: Bool) throws {
        guard let engine else { return }
        
        let indices = (0..<text.count)
        let delay = duration / (CGFloat(indices.count))
        
        var events: [CHHapticEvent] = []
        
        // Just a simple haptic patter, can customize it
        if forDismiss {
            events = [
                CHHapticEvent(eventType: .hapticContinuous, parameters: [
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2),
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.1)
                ], relativeTime: 0, duration: duration)
            ]
        } else {
            events = indices.compactMap { index in
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5),
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4)
                ], relativeTime: CGFloat(index) * delay)
            }
        }
        
        let pattern = try CHHapticPattern(events: events, parameters: [])
        let player = try engine.makePlayer(with: pattern)
        try player.start(atTime: CHHapticTimeImmediate)
    }
}

#Preview {
    NavigationStack {
        DemoHostView(demo: .typeWriterEffect)
    }
}
