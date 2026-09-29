# Como adicionar uma demo

Três passos. Nunca é preciso abrir o Xcode nem editar o `.pbxproj`.

```
1. cp -R _Template MinhaCoisa          # copie a pasta
2. edite MinhaCoisa/*.swift            # a View + o descritor Demo
3. registre em ../Catalog/DemoRegistry.swift
```

O projeto usa `PBXFileSystemSynchronizedRootGroup`: qualquer `.swift` ou `.metal`
criado dentro de `New-Features-Project/` entra no target automaticamente.

## O que você ganha sem escrever nada

Card na lista · busca por título, summary, API e tag · filtro por categoria ·
chrome padrão com título · painel "o que isso faz" · botão de reiniciar.

## O descritor

```swift
extension Demo {
    static let minhaCoisa = Demo.make(
        id: "shaders.minha-coisa",   // CONTRATO — não mude depois de registrado
        title: "Minha coisa",
        summary: "Uma linha para o card",
        explanation: "O que faz e qual é o truque.",
        symbol: "sparkles",
        category: .shaders,
        apis: ["colorEffect"],        // vira chip e entra na busca
        tags: ["metal"]
    ) { MinhaCoisaView() }
}
```

E em `DemoRegistry.all`, uma linha: `.minhaCoisa,`

## Três regras

**1 — Identidade estável.** O host prende a demo a um `runID` que só muda no botão
reiniciar, então rotação e Split View não recriam a tela. Você quebra isso se
ramificar o layout de um jeito que destrua identidade — prefira `AnyLayout`,
`ViewThatFits` e `containerRelativeFrame` a `if isCompact { HStack } else { VStack }`.

**2 — Reduce Motion.** Use `.motion(_:value:)` do `DesignSystem/Motion.swift` em vez
de `.animation` direto, ou leia `\.accessibilityReduceMotion`. Toda demo precisa de
um caminho degradado que ainda faça sentido (ver `FireShader`).

**3 — Curvas nomeadas.** Prefira `Motion.tap` / `.state` / `.enter` / `.bouncy` a
literais soltos — a comparação entre técnicas só é justa com o mesmo tempo base.

## Demos de referência

- **`PhaseAnimatorHeart/`** — o caso mais simples: SwiftUI puro, um arquivo.
- **`FireShader/`** — com `.metal`. Copie esta se for fazer shader: o encanamento
  (`[[ stitchable ]]`, `ShaderLibrary`, `TimelineView`) já está resolvido.
