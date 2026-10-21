import Foundation

/// A single founder story shown in the feed.
/// Pure data: no SwiftUI / AVFoundation imports, so it is trivial to test and reuse.
struct FounderVideo: Identifiable, Hashable {

    /// Decorative placeholder style used instead of a remote thumbnail.
    enum ThumbnailStyle: String, Hashable, CaseIterable {
        case sunrise, ocean, forest, violet, ember, slate
    }

    let id: String
    let title: String
    let founderName: String
    let founderRole: String
    let summary: String
    let category: String
    let duration: TimeInterval
    /// Name (without extension) of a bundled mp4. `nil` means no video is available yet.
    let videoFileName: String?
    let thumbnailStyle: ThumbnailStyle
    let thumbnailSymbol: String
}

extension FounderVideo {
    /// "2:05" style label for the duration badge.
    var formattedDuration: String {
        let total = Int(duration)
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}
