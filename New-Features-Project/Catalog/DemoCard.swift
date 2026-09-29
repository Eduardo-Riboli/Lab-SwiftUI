import SwiftUI

/// A linha/card de uma demo na lista. Deriva tudo de `DemoMetadata` — uma demo
/// nova ganha card sem escrever nada aqui.
struct DemoCard: View {
    let metadata: DemoMetadata

    var body: some View {
        HStack(spacing: 14) {
            icon

            VStack(alignment: .leading, spacing: 3) {
                Text(metadata.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(metadata.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                if let api = metadata.apis.first {
                    Text(api)
                        .font(.caption2.monospaced())
                        .foregroundStyle(metadata.category.tint)
                        .padding(.top, 2)
                }
            }
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(metadata.title). \(metadata.summary)")
    }

    private var icon: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(metadata.category.tint.gradient)
            .frame(width: 46, height: 46)
            .overlay {
                Image(systemName: metadata.symbol)
                    .font(.title3)
                    .foregroundStyle(.white)
            }
            .accessibilityHidden(true)
    }
}
