import SwiftUI
import MapKit

// MARK: - Registro
extension Demo {
    static let verticalTabBar = Demo.make(
        id: "components.verticalTabBar",
        title: "Vertical Segmented Control",
        summary: "Picker segmentado nativo girado 90° sobre um mapa",
        explanation: """
            Um seletor vertical de modos de mapa, no estilo do app Mapas, feito \
            com o `Picker` segmentado nativo em vez de um controle desenhado do \
            zero. Você ganha de graça o thumb deslizante, o feedback de toque e a \
            acessibilidade do sistema.

            O truque é girar o controle inteiro com `rotationEffect(.degrees(90))` \
            e desfazer a rotação só nos ícones. Cada SF Symbol vira um `CGImage` e \
            é recriado com `Image(decorative:scale:orientation: .left)`, então a \
            imagem já nasce girada -90° e os dois giros se cancelam: o controle \
            fica de pé, os ícones ficam retos.

            Como `rotationEffect` não altera o layout, a ordem dos `frame` \
            importa: o primeiro define o tamanho deitado (largura = número de \
            itens × altura do item), e o segundo, depois da rotação, reserva o \
            espaço já em pé. A versão `UIViewRepresentable` faz o mesmo com \
            `UISegmentedControl`, invertendo largura e altura em `sizeThatFits` e \
            permitindo esconder o fundo para deixar só o `glassEffect`.
            """,
        symbol: "rectangle.split.1x2",
        category: .components,
        apis: ["Picker", "rotationEffect", "glassEffect", "MapStyle", "UIViewRepresentable"],
        tags: ["Segmented Control", "Mapa", "Tab Bar", "Vertical"]
    ) { VerticalTabBarView() }
}

// Sample Enum
enum Mode: String, VerticalItem {
    case explore = "Explore"
    case night = "Night"
    case satellite = "Satellite"
    
    var symbol: String {
        switch self {
        case .explore: return "map.fill"
        case .night: return "moon.stars.fill"
        case .satellite: return "globe.americas.fill"
        }
    }

    var mapStyle: MapStyle {
        switch self {
        case .explore, .night:
            return .standard(elevation: .realistic, pointsOfInterest: .all)
        case .satellite:
            return .hybrid(elevation: .realistic)
        }
    }

    var colorScheme: ColorScheme {
        self == .night ? .dark : .light
    }
}

private var location: CLLocationCoordinate2D {
    CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275)
}

// Street-level camera: ~800 m from the ground, tilted to show the roads in 3D.
private var camera: MapCamera {
    MapCamera(centerCoordinate: location, distance: 800, heading: 0, pitch: 60)
}

// MARK: - Demo
struct VerticalTabBarView: View {
    @State private var position: MapCameraPosition = .camera(camera)
    @State private var activeMode: Mode = .explore
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            ZStack(alignment: .bottomTrailing) {
                Map(position: $position)
                    .mapStyle(activeMode.mapStyle)
                    .environment(\.colorScheme, activeMode.colorScheme)
                    .frame(width: size.width, height: size.height)

                VerticalSegmentedControl(selection: $activeMode)
                    .glassEffect(.regular.interactive(), in: .capsule)
                    .padding()
            }
        }
    }
}

protocol VerticalItem: CaseIterable, Hashable {
    var symbol: String { get }
}

struct VerticalSegmentedControl<Value: VerticalItem>: View {
    @Binding var selection: Value
    private var pointSize: CGFloat = 18 // Icon Size
    @Environment(\.displayScale) private var displayScale
    
    var body: some View {
        // Large ControlSize value is approx: 48
        let itemWidth: CGFloat = 50
        let itemHeight: CGFloat = 60
        let pickerHeight: CGFloat = CGFloat(Value.allCases.count) * itemHeight
        
        Picker("", selection: $selection) {
            ForEach(Array(Value.allCases), id: \.symbol) { item in
                // Rotating Image using Native Image Orientation
                let config = UIImage.SymbolConfiguration(pointSize: pointSize)
                if let cgImage = UIImage(systemName: item.symbol)?
                    .withConfiguration(config).cgImage {
                    Image(decorative: cgImage, scale: displayScale, orientation: .left)
                        .tag(item)
                }
            }
        }
        .labelsHidden()
        .pickerStyle(.segmented)
        .controlSize(.large)
        .frame(width: pickerHeight, height: itemWidth)
        // Rotating
        .rotationEffect(.init(degrees: 90))
        .frame(width: itemWidth, height: pickerHeight)
        // Background so the picker stays legible over any map region
//        .background(.regularMaterial, in: .capsule)
//        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
    }
}

// MARK: - Version of Custom Segmented Control
struct CustomSegmentedControl<Value: VerticalItem>: View {
    var tint: Color = Color.gray.opacity(0.35)
    var pointSize: CGFloat
    @Binding var selection: Value
    
    var body: some View {
        let itemWidth: CGFloat = 50
        let itemHeight: CGFloat = 60
        let pickerHeight: CGFloat = CGFloat(Value.allCases.count) * itemHeight
        
        VerticalSegmentedSCView(pointSize: pointSize, tint: tint, selection: $selection)
            .rotationEffect(.init(degrees: 90))
            .frame(width: itemWidth, height: pickerHeight)
            .padding(2)
            .glassEffect(.regular.interactive(), in: .capsule)
    }
}

fileprivate struct VerticalSegmentedSCView<Value: VerticalItem>: UIViewRepresentable {
    var pointSize: CGFloat
    var tint: Color
    @Binding var selection: Value
    @Environment(\.displayScale) private var displayScale
    
    func makeUIView(context: Context) -> UISegmentedControl {
        let items: [UIImage] = Value.allCases.compactMap { item in
            let config = UIImage.SymbolConfiguration(pointSize: pointSize)
            guard let cgImage = UIImage(systemName: item.symbol)?
                .withConfiguration(config).cgImage else {
                return nil
            }
            
            return UIImage(cgImage: cgImage, scale: displayScale, orientation: .left)
        }
        
        let control = UISegmentedControl(items: items)
        control.selectedSegmentTintColor = UIColor(tint)
        control.selectedSegmentIndex = Array(Value.allCases).firstIndex(of: selection) ?? 0
        control.addTarget(context.coordinator, action: #selector(context.coordinator.valueChanged(_:)), for: .valueChanged)
        
        // If you want remove the background
        DispatchQueue.main.async {
            removeBackgroundColor(control)
        }
        
        return control
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        let index = Array(Value.allCases).firstIndex(of: selection) ?? 0
        if uiView.selectedSegmentIndex != index {
            uiView.selectedSegmentIndex = index
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(selection: $selection)
    }
    
    class Coordinator: NSObject {
        @Binding var selection: Value
        init(selection: Binding<Value>) {
            _selection = selection
        }
        
        @objc func valueChanged(_ sender: UISegmentedControl) {
            selection = Array(Value.allCases)[sender.selectedSegmentIndex]
        }
    }
    
    private func removeBackgroundColor(_ control: UISegmentedControl) {
        for subview in control.subviews {
            if subview is UIImageView && subview != control.subviews.last {
                subview.alpha = 0
            }
        }
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UISegmentedControl, context: Context) -> CGSize? {
        let size = proposal.replacingUnspecifiedDimensions()
        // Flipping contents
        return .init(width: size.height, height: size.width)
    }
}

#Preview {
    NavigationStack {
        DemoHostView(demo: .verticalTabBar)
    }
}
