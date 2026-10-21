import SwiftUI

struct FeedItemCard: View {

    let video: FounderVideo

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ThumbnailView(style: video.thumbnailStyle, symbolName: video.thumbnailSymbol)
                .aspectRatio(16 / 9, contentMode: .fit)
                .overlay(alignment: .bottomLeading) {
                    Image(systemName: "play.circle.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                        .shadow(radius: 4)
                        .padding(10)
                }
                .overlay(alignment: .bottomTrailing) {
                    if video.videoFileName != nil {
                        DurationBadge(text: video.formattedDuration)
                            .padding(10)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(video.title)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                Text(video.founderName)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                Text(video.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(
            Color(.secondarySystemBackground),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens story details")
    }
}

private struct DurationBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption2.monospacedDigit().weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(.black.opacity(0.6), in: Capsule())
    }
}

#Preview {
    FeedItemCard(video: MockFeedService.sampleItems[0])
        .padding()
}
