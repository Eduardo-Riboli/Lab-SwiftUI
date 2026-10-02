import SwiftUI

// MARK: - Registro
extension Demo {
    static let chatBubbleTransition = Demo.make(
        id: "transitions.chatBubbleTransition",
        title: "Chat Bubble Transition",
        summary: "A mensagem sai do campo de texto e vira bolha no chat",
        explanation: """
            A transição de envio do iMessage: ao tocar em enviar, o texto sai \
            do campo de digitação e se transforma na bolha da conversa, enquanto \
            as mensagens anteriores dão um pequeno "empurrão" para baixo.

            O truque é que a mensagem entra na lista no mesmo instante do envio, \
            mas invisível. Enquanto ela ainda é a `currentMessage`, uma cópia \
            temporária fica sobreposta ao `TextField` com o mesmo \
            `matchedGeometryEffect`. Ao limpar a mensagem atual dentro de \
            `withAnimation`, a cópia some, a bolha real aparece e o SwiftUI \
            anima a geometria de uma para a outra.

            Antes de enviar, o texto é medido com `NSString.size(withAttributes:)`. \
            Se cabe numa linha do campo, a bolha anima posição e tamanho; se não, \
            só a posição, evitando que o texto quebre de forma diferente no meio \
            do caminho. O `keyframeAnimator` cria o empurrão das outras bolhas, \
            usando a altura do campo propagada via `@Entry` no `Environment`, e \
            o `defaultScrollAnchor(.bottom)` mantém o chat ancorado embaixo.
            """,
        symbol: "bubble.left.and.text.bubble.right",
        category: .transitions,
        apis: ["matchedGeometryEffect", "keyframeAnimator", "withAnimation", "defaultScrollAnchor", "onGeometryChange", "glassEffect"],
        tags: ["Chat", "Mensagem", "iMessage", "Bolha", "TextField"]
    ) { ChatBubbleTransition() }
}

// Message field size shared with the bubbles (width limit + push offset)
extension EnvironmentValues {
    @Entry var messageFieldSize: CGSize = .zero
}

// Sample Model
struct Message: Identifiable {
    var id: String
    var content: String
    var isFit: Bool?

    init(content: String) {
        self.id = UUID().uuidString
        self.content = content
        self.isFit = nil
    }

    static var placeholderMessages: [Message] {
        [
            .init(content: "Hello, my name is Eduardo"),
            .init(content: "This is Chat Bubble Transition Using SwiftUI!"),
        ]
    }
}

// MARK: - Demo
struct ChatView: View {
    @State private var allMessages: [Message] = Message.placeholderMessages
    @State private var currentMessage: Message = .init(content: "")
    @State private var messageFieldSize: CGSize = .zero
    @Namespace private var namespace

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                ForEach(allMessages) { message in
                    // Checking if the message is currently typing one waits to animate!
                    let isVisible = currentMessage.id != message.id
                    
                    MessageBubble(
                        isVisible: isVisible,
                        message: message,
                        namespace: namespace
                    )
                }
            }
            .padding(15)
        }
        // Setting Default Scroll Anchor to Bottom, thus we automatically get the bottom to top scroll
        .defaultScrollAnchor(.bottom)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            BottomBar()
        }
        .environment(\.messageFieldSize, messageFieldSize)
    }

    // Bottom bar
    @ContentBuilder
    private func BottomBar() -> some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField(
                "Type a message",
                text: $currentMessage.content,
                axis: .vertical
            )
            .font(.body)
            .lineLimit(6)
            .padding(horizontalPadding)
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 25))
            .overlay(alignment: .topLeading) {
                ForEach(allMessages) {
                    if currentMessage.id == $0.id {
                        TemporaryMessageTransitionSource(currentMessage)
                    }
                }
            }
            .onGeometryChange(for: CGSize.self) {
                $0.size
            } action: { newValue in
                messageFieldSize = newValue
            }

            Button(action: sendMessage) {
                Image(systemName: "paperplane")
                    .font(.body)
                    .fontWeight(.semibold)
                    .frame(width: 25, height: 35)
            }
            .buttonStyle(.glassProminent)
            .buttonBorderShape(.circle)
            .disabled(currentMessage.content.isEmpty)
        }
        .padding(.horizontal, 15)
        .padding(.bottom, 10)
    }
    
    // Temporary transition source view on top of the message field to transition from source destination
    @ContentBuilder
    private func TemporaryMessageTransitionSource(_ message: Message) -> some View {
        let isFit = message.isFit ?? false
        
        Text(message.content)
            .font(.body)
            .padding(12)
            .frame(maxWidth: isFit ? .infinity : nil, alignment: .leading)
            .background(Color(UIColor.systemGray6))
            .clipShape(.rect(cornerRadius: 25))
            .matchedGeometryEffect(id: message.id, in: namespace, properties: isFit ? [.position, .size] : [.position])
    }

    private func sendMessage() {
        let textWidth = calculateTextSize(
            text: currentMessage.content,
            fontStyle: .body
        ).width
        let contentPadding: CGFloat = horizontalPadding * 2
        let isFit = textWidth < (messageFieldSize.width - contentPadding)
        currentMessage.isFit = isFit

        allMessages.append(currentMessage)
        DispatchQueue.main.async {
            let reference = currentMessage
            
            // Animation from textfield to message block using matched geometry effect
            withAnimation(animation, completionCriteria: .removed) {
                currentMessage = .init(content: "")
            } completion: {
                if let index = allMessages.firstIndex(where: { $0.id == reference.id } ) {
                    allMessages[index].isFit = nil
                }
            }
        }
    }

    private func calculateTextSize(text: String, fontStyle: UIFont.TextStyle)
        -> CGSize
    {
        NSString(string: text).size(withAttributes: [
            .font: UIFont.preferredFont(forTextStyle: fontStyle)
        ])
    }

    private var animation: Animation {
        .interpolatingSpring(duration: 0.3, bounce: 0, initialVelocity: 0)
    }

    private var horizontalPadding: CGFloat {
        12
    }
}

struct MessageBubble: View {
    var isVisible: Bool
    var message: Message
    var namespace: Namespace.ID
    @Environment(\.messageFieldSize) private var messageFieldSize

    var body: some View {
        let isFit = message.isFit ?? false
        
        ZStack {
            if isVisible {
                Text(message.content)
                    .font(.body)
                    .padding(12)
                    .frame(maxWidth: isFit ? .infinity : nil, alignment: .leading)
                    .background(Color(UIColor.systemGray6))
                    .clipShape(.rect(cornerRadius: 25))
                    .matchedGeometryEffect(id: message.id, in: namespace, properties: isFit ? [.position, .size] : [.position])
                    // Spacing top
                    .padding(.top, 10)
            }
        }
        .fixedSize(horizontal: isFit ? isVisible : false, vertical: true)
        .compositingGroup()
        // Adding a option Bottom Push Offset Effect
        .keyframeAnimator(initialValue: CGFloat.zero, trigger: isVisible) { [messageFieldSize] content, progress in
            content
                .offset(y: (messageFieldSize.height * 0.55) * progress)
        } keyframes: { _ in
            CubicKeyframe(1, duration: 0.15)
            CubicKeyframe(0, duration: 0.15)
        }
        // Limiting it's width to the max of message field width
        .frame(maxWidth: messageFieldSize.width, alignment: .trailing)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

struct ChatBubbleTransition: View {
    var body: some View {
        ChatView()
    }
}

#Preview {
    NavigationStack {
        DemoHostView(demo: .chatBubbleTransition)
    }
}
