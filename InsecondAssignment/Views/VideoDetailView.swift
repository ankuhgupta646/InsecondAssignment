import SwiftUI

struct VideoDetailView: View {

    let video: FounderVideo

    @StateObject private var playerViewModel: VideoPlayerViewModel
    @Environment(\.scenePhase) private var scenePhase

    init(video: FounderVideo) {
        self.video = video
        _playerViewModel = StateObject(
            wrappedValue: VideoPlayerViewModel(videoFileName: video.videoFileName)
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VideoPlayerSection(viewModel: playerViewModel, video: video)
                    .padding(.horizontal)

                info
                    .padding(.horizontal)
            }
            .padding(.vertical, 8)
        }
        .navigationTitle("Story")
        .navigationBarTitleDisplayMode(.inline)
        // Player lifecycle is tied to this screen's visibility.
        .onAppear { playerViewModel.prepare() }
        .onDisappear { playerViewModel.stop() }
        // Don't keep playing if the app goes to background / is interrupted.
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase != .active { playerViewModel.pause() }
        }
    }

    private var info: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(video.category.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tint)

            Text(video.title)
                .font(.title2.bold())

            HStack(spacing: 10) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.title)
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(video.founderName)
                        .font(.subheadline.weight(.semibold))
                    Text(video.founderRole)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(video.summary)
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        VideoDetailView(video: MockFeedService.sampleItems[0])
    }
}
