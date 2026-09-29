import SwiftUI

struct RootView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router

        // Os destinos (e a transição de zoom) são declarados pelo `CatalogView`,
        // que é quem conhece os cards de origem.
        NavigationStack(path: $router.path) {
            CatalogView()
        }
    }
}

#Preview {
    RootView()
        .environment(AppRouter())
}
