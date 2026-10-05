import SwiftUI

@MainActor
enum DemoRegistry {

    // MARK: - Registro

    static let all: [Demo] = [
        .phaseAnimatorHeart,
        .fireShader,
        .safariCollapsibleBottomBar,
        .verticalTabBar,
        .chatBubbleTransition,
        .typeWriterEffect
    ]

    // MARK: - Consultas

    static let metadata: [DemoMetadata] = all.map(\.metadata)

    private static let byID: [String: Demo] = Dictionary(
        uniqueKeysWithValues: all.map { ($0.id, $0) }
    )

    static func demo(id: String) -> Demo? { byID[id] }

    static func metadata(id: String) -> DemoMetadata? { byID[id]?.metadata }

    static let populatedCategories: [DemoCategory] = {
        let present = Set(all.map(\.metadata.category))
        return DemoCategory.allCases.filter(present.contains)
    }()

    static func search(_ query: String, category: DemoCategory? = nil) -> [DemoMetadata] {
        metadata.filter { item in
            (category == nil || item.category == category) && item.matches(query)
        }
    }
}
