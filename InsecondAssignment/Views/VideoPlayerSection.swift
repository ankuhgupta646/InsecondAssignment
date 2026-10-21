import SwiftUI
import AVKit

/// 16:9 player area: placeholder underneath, AVPlayer on top, state-dependent overlay.
struct VideoPlayerSection: View {

    @ObservedObject var viewModel: VideoPlayerViewModel
    let video: FounderVideo

    var body: some View {
        ZStack {
            ThumbnailView(style: video.thumbnailStyle, symbolName: video.thumbnailSymbol)

            if let player = viewModel.player {
                AVPlayerRepresentable(player: player)
                    .allowsHitTesting(false)
            }

            overlay
        }
        .aspectRatio(16 / 9, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture { viewModel.togglePlayback() }
    }

    @ViewBuilder
    private var overlay: some View {
        switch viewModel.state {
        case .idle:
            EmptyView()
        case .loading:
            ProgressView().tint(.white)
        case .ready:
            playPauseButton
        case .unavailable(let message):
            messageOverlay(message, showsRetry: false)
        case .failed(let message):
            messageOverlay(message, showsRetry: true)
        }
    }

    private var playPauseButton: some View {
        Button {
            viewModel.togglePlayback()
        } label: {
            Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                .font(.title)
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(.black.opacity(0.45), in: Circle())
        }
        .opacity(viewModel.isPlaying ? 0.4 : 1)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isPlaying)
        .accessibilityLabel(viewModel.isPlaying ? "Pause video" : "Play video")
    }

    private func messageOverlay(_ message: String, showsRetry: Bool) -> some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title2)
            Text(message)
                .font(.footnote)
                .multilineTextAlignment(.center)
            if showsRetry {
                Button("Retry") { viewModel.retry() }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
            }
        }
        .foregroundStyle(.white)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black.opacity(0.55))
    }
}

/// Thin wrapper around AVPlayerViewController with the system controls hidden,
/// so our own play/pause UI is the single source of interaction.
struct AVPlayerRepresentable: UIViewControllerRepresentable {

    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspect
        return controller
    }

    func updateUIViewController(_ controller: AVPlayerViewController, context: Context) {
        if controller.player !== player {
            controller.player = player
        }
    }
}
