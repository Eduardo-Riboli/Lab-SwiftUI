# New Features Project

Um laboratório vivo: cada animação moderna ou capacidade nova da plataforma Apple
vira uma demo isolada, navegável e comparável.

**Requisitos:** Xcode 27 · iOS 27 · Swift 6.

## Rodar

```bash
open New-Features-Project.xcodeproj
```

Pela linha de comando:

```bash
xcodebuild -project New-Features-Project.xcodeproj -scheme New-Features-Project \
           -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Para abrir uma demo direto, sem navegar — útil ao iterar e para automatizar
captura de tela:

```bash
xcrun simctl launch booted com.riboli.NewFeaturesProject -demo shaders.fire
```

> **Numa máquina nova:** o projeto compila shaders Metal, que dependem de um
> componente separado do Xcode. Se o build falhar com
> `cannot execute tool 'metal'`, instale-o uma vez com
> `xcodebuild -downloadComponent MetalToolchain` (~900 MB).

## Adicionar uma demo

Três passos, descritos em [`New-Features-Project/Demos/README.md`](New-Features-Project/Demos/README.md):
copiar a pasta `_Template`, escrever a `View`, e somar uma linha em `DemoRegistry.all`.

Nunca é preciso editar o `.pbxproj` — o target usa
`PBXFileSystemSynchronizedRootGroup`, então arquivos novos no disco entram sozinhos.

## Estrutura

| Pasta | O que é |
|---|---|
| `App/` | Entrada, router e a raiz da navegação |
| `Catalog/` | O modelo de demo, o registry e toda a UI do catálogo |
| `DesignSystem/` | Curvas de animação nomeadas e o modificador que respeita Reduce Motion |
| `Demos/` | Uma pasta por demo. `_Template/` é o esqueleto para copiar |

O `DemoRegistry` é a única fonte de verdade: card, busca, filtro e navegação
derivam todos dele.

## Estado

A base está pronta, com duas demos de referência (`PhaseAnimatorHeart` para
SwiftUI puro, `FireShader` para o encanamento Metal). O roadmap completo — 136
features catalogadas em seis pilares, incluindo Liquid Glass, FoundationModels
e Siri via App Intents — está no documento de design do projeto.
