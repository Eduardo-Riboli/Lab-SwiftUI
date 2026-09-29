import Foundation
import Observation

/// Dono do caminho de navegação.
///
/// O caminho guarda **ids de demo, não views**. Isso mantém a navegação
/// serializável e endereçável por fora do SwiftUI — é o que vai permitir que um
/// deep link ou um App Intent da Siri abram uma demo sem tocar na camada de UI.
@Observable
@MainActor
final class AppRouter {
    var path: [String] = []

    init() {
        if let id = Self.demoFromLaunchArguments {
            path = [id]
        }
    }

    /// `-demo <id>` nos argumentos de lançamento abre a demo direto.
    ///
    /// Serve para iterar sem navegar toda vez, e para automatizar captura de
    /// tela no simulador:
    /// `xcrun simctl launch <udid> com.riboli.NewFeaturesProject -demo shaders.fire`
    private static var demoFromLaunchArguments: String? {
        let args = ProcessInfo.processInfo.arguments
        guard let flag = args.firstIndex(of: "-demo"), args.indices.contains(flag + 1) else {
            return nil
        }
        let id = args[flag + 1]
        return DemoRegistry.demo(id: id) != nil ? id : nil
    }

    func open(_ id: String) {
        guard DemoRegistry.demo(id: id) != nil else { return }
        path = [id]
    }

    func popToRoot() {
        path.removeAll()
    }
}
