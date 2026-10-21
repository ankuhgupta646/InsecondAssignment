import SwiftUI

/// Gradient + SF Symbol placeholder used as the thumbnail (no network, no assets needed).
struct ThumbnailView: View {

    let style: FounderVideo.ThumbnailStyle
    let symbolName: String

    var body: some View {
        ZStack {
            LinearGradient(
                colors: style.colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: symbolName)
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(.white.opacity(0.85))
        }
        .accessibilityHidden(true)
    }
}

/// SwiftUI colours live in the view layer, keeping `FounderVideo` free of UI imports.
extension FounderVideo.ThumbnailStyle {
    var colors: [Color] {
        switch self {
        case .sunrise: return [.orange, .pink]
        case .ocean:   return [.blue, .teal]
        case .forest:  return [.green, .mint]
        case .violet:  return [.purple, .indigo]
        case .ember:   return [.red, .orange]
        case .slate:   return [.gray, .black.opacity(0.7)]
        }
    }
}
