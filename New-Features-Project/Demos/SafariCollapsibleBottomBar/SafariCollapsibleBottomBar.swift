import SwiftUI

// MARK: - Registro
extension Demo {
    static let safariCollapsibleBottomBar = Demo.make(
        id: "components.safariCollapsibleBottomBar",
        title: "Safari's Collapsible Bottom Bar",
        summary: "Barra que vira pílula de vidro ao arrastar o dedo",
        explanation: """
            A barra de baixo do Safari encolhe numa pílula quando você rola para \
            baixo e volta ao tamanho cheio quando rola para cima. O efeito parece \
            óbvio, mas o que o faz sentir certo é justamente não estar preso ao \
            offset do scroll.

            O truque está no `@GestureState isDragging` somado ao \
            `guard isDragging else { return }`: só o dedo encostado na tela move a \
            transição. Durante a desaceleração por inércia o `onScrollGeometryChange` \
            continua disparando, mas é ignorado — sem essa guarda a barra continuaria \
            se mexendo sozinha depois que você solta.

            O `progress`, de 0 a 1, é um acumulador que dá uma prévia contínua e \
            reversível: enquanto ele sobe, o `scaleEffect` ancorado embaixo estica a \
            barra na direção do estado que está por vir, e você ainda pode desistir \
            voltando o dedo. Ao soltar, `onGestureEnd` soma a velocidade do gesto, \
            então um peteleco rápido confirma a mudança mesmo com o progresso ainda \
            abaixo da metade.

            A parte visual é um único `glassEffect` sobre uma `ConcentricRectangle` \
            cujos cantos acompanham os da tela. Como é a mesma view mudando de forma, \
            e não duas se substituindo, o Liquid Glass morfa entre os dois estados em \
            vez de fazer cross-fade.
            """,
        symbol: "safari",
        category: .transitions,
        apis: ["onScrollGeometryChange", "glassEffect", "ConcentricRectangle", "GestureState", "safeAreaInset"],
        tags: ["Transition", "Safari", "Search"]
    ) { SafariCollapsibleBottomBar() }
}

// MARK: - Demo
struct SafariCollapsibleBottomBar: View {
    @State private var safeArea: EdgeInsets = .init()
    @State private var text: String = ""
    @State private var isMinimised: Bool = false
    // Interactive Scroll Minimize/Maximize Properties
    @GestureState private var isDragging: Bool = false
    @State private var progress: CGFloat = 0
    
    var body: some View {
        ScrollView(.vertical) {
            Rectangle()
                .foregroundStyle(.clear)
                .frame(height: 2000)
        }
        .scrollDismissesKeyboard(.interactively)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(.rect)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .updating($isDragging) { _, out, _ in
                    out = true
                }.onEnded { value in
                    onGestureEnd(value: value)
                }
        )
        .onScrollGeometryChange(for: CGFloat.self) {
            $0.contentOffset.y + $0.contentInsets.top
        } action: { oldValue, newValue in
            guard isDragging else { return }
            handleScroll(oldValue: oldValue, newValue: newValue)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            SFBottomBar(
                safeArea: safeArea,
                text: $text,
                isMinimised: $isMinimised,
                progress: $progress
            ) {
                SFBAction(symbol: "chevron.left") {
                 
                }
                
                SFBAction(symbol: "chevron.right") {
                 
                }
                
                SFBAction(symbol: "square.and.arrow.up") {
                 
                }
                
                SFBAction(symbol: "bookmark") {
                    
                }
                
                SFBAction(symbol: "square.on.square") {
                    
                }
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .onGeometryChange(for: EdgeInsets.self) {
            $0.safeAreaInsets
        } action: { newValue in
            safeArea = newValue
        }
    }
    
    private func handleScroll(oldValue: CGFloat, newValue: CGFloat) {
        let delta = (newValue / oldValue) / transitionDistance
        let progress = max(0, progress + (isMinimised ? -delta : delta))
        
        if progress >= 1 {
            withAnimation(animation) {
                isMinimised.toggle()
                self.progress = 0
            }
        } else {
            self.progress = progress
        }
    }
    
    private func onGestureEnd(value: DragGesture.Value) {
        // Adjust velocity with you want
        let velocity = -value.velocity.height * 0.1
        let velocityProgress = velocity / transitionDistance
        
        let progress = progress + (isMinimised ? -velocityProgress : velocityProgress)
        
        withAnimation(animation) {
            if progress >= 0.5 {
                isMinimised.toggle()
            }
            
            self.progress = 0
        }
    }
    
    private var transitionDistance: CGFloat {
        // Adjust distance with you want
        return 120
    }
    
    private var animation: Animation {
        .interpolatingSpring(duration: 0.3, bounce: 0, initialVelocity: 0)
    }
}

// MARK: - Helpers
struct SFBAction: Identifiable {
    private(set) var id: String = UUID().uuidString
    var symbol: String
    var action: () -> ()
}

@resultBuilder
struct SFBActionBuilder {
    static func buildBlock(_ actions: SFBAction...) -> [SFBAction] {
        actions
    }
}

struct SFBottomBar: View {
    var safeArea: EdgeInsets
    @Binding var text: String
    @Binding var isMinimised: Bool
    @Binding var progress: CGFloat
    @SFBActionBuilder var actions: [SFBAction]
    // View Properties
    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        VStack(spacing: isMinimised ? 0 : 10) {
            ZStack {
                if isMinimised {
                    Text(text.isEmpty ? "Search here" : text)
                        .font(isMinimised ? .caption : .body)
                        .foregroundStyle(text.isEmpty ? .secondary : .primary)
                        .lineLimit(1)
                        .padding(.horizontal, 20)
                } else {
                    Capsule()
                        .fill(.clear)
                }
            }
            .frame(height: isMinimised ? 35 : 45)
            HStack(spacing: 0) {
                ForEach(actions) { action in
                    ActionView(action)
                }
            }
            .compositingGroup()
            .opacity(isMinimised ? 0 : 1)
            .blur(radius: isMinimised ? 10 : 0)
            .frame(
                width: isMinimised ? 0 : nil,
                height: isMinimised ? 0 : nil,
                alignment: .top
            )
            .padding(.horizontal, isMinimised ? 0 : -15)
        }
        .compositingGroup()
        .padding(isMinimised ? 0 : 18)
        .clipShape(.rect(cornerRadius: 30))
        .overlay {
            if isMinimised {
                Rectangle()
                    .foregroundStyle(.clear)
                    .contentShape(.rect)
                    .onTapGesture {
                        isMinimised = false
                    }
                    .transition(.identity)
            }
        }
        .glassEffect(
            .regular.interactive(isMinimised),
            in: ConcentricRectangle(corners: .concentric(minimum: .fixed(30)), isUniform: true)
        )
        .animation(animation.speed(1.5)) {
            $0.opacity(isFocused ? 0 : 1)
        }
        .overlay(alignment: isFocused ? .bottom : .top) {
            SearchBar()
                .padding(isFocused || isMinimised ? 0 : 18)
                .opacity(isMinimised ? 0 : 1)
                .allowsHitTesting(!isMinimised)
        }
        .padding([.horizontal, .bottom], 18)
        .scaleEffect(1 + (isMinimised ? 0.1 : -0.1) * progress, anchor: .bottom)
        .frame(maxWidth: isMinimised ? 180 : nil)
        .animation(animation, value: isMinimised)
    }
    
    // Search Bar
    @ContentBuilder
    private func SearchBar() -> some View {
        ZStack(alignment: .leading) {
            Image(systemName: "magnifyingglass")
                .font(.callout)
                .opacity(isFocused ? 0 : 1)
            
            TextField("Search Here", text: $text)
                .padding(.leading, isFocused ? 0 : 30)
        }
        .padding(.horizontal, 15)
        .frame(height: isMinimised ? 32 : 45)
        .background {
            if colorScheme == .dark {
                Capsule()
                    .fill(.black)
            } else {
                Capsule()
                    .fill(.regularMaterial)
            }
        }
        .tint(Color.white)
        .environment(\.colorScheme, .dark)
        .padding(.trailing, isFocused ? 55 : 0)
        .background(alignment: .trailing) {
            Button {
                isFocused = false
            } label: {
                Image(systemName: "xmark")
                    .frame(width: 20, height: 30)
            }
            .buttonStyle(.glass)
            .animation(animation.speed(2)) {
                $0.opacity(isFocused ? 1 : 0)
            }
        }
        .focused($isFocused)
        // Only moving this with keyboard
        .offset(y: isFocused ? -safeArea.bottom : 0)
        .animation(animation, value: isFocused)
    }
    
    // Action View
    @ContentBuilder
    private func ActionView(_ item: SFBAction) -> some View {
        Button(action: item.action) {
            Image(systemName: item.symbol)
                .font(.title3)
                .frame(width: 45, height: 45)
                .foregroundStyle(Color.primary)
                .contentShape(.rect)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var animation: Animation {
        .interpolatingSpring(duration: 0.3, bounce: 0, initialVelocity: 0)
    }
}

#Preview {
    NavigationStack {
        DemoHostView(demo: .safariCollapsibleBottomBar)
    }
}
