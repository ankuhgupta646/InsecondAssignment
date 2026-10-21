import AVFoundation
import Combine
import os

/// Owns exactly one `AVPlayer` for the detail screen and manages its whole lifecycle:
/// create on appear -> observe -> pause/release on disappear.
@MainActor
final class VideoPlayerViewModel: ObservableObject {

    enum PlaybackState: Equatable {
        case idle
        case loading
        case ready
        /// No playable asset exists (nil file name, or file missing). Retrying won't help.
        case unavailable(String)
        /// The asset exists but AVFoundation failed to play it. Retry is offered.
        case failed(String)
    }

    @Published private(set) var state: PlaybackState = .idle
    @Published private(set) var isPlaying = false
    @Published private(set) var player: AVPlayer?

    private let videoFileName: String?
    private let fileExtension: String
    private let bundle: Bundle
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: "com.inseconds.feed", category: "Playback")

    init(videoFileName: String?, fileExtension: String = "mp4", bundle: Bundle = .main) {
        self.videoFileName = videoFileName
        self.fileExtension = fileExtension
        self.bundle = bundle
    }

    // MARK: - Lifecycle

    /// Creates the player lazily. Safe to call repeatedly.
    func prepare() {
        guard player == nil else { return }

        guard let name = videoFileName else {
            state = .unavailable("The video for this story is coming soon.")
            return
        }
        guard let url = bundle.url(forResource: name, withExtension: fileExtension) else {
            logger.error("Missing bundled video \(name).\(self.fileExtension)")
            state = .unavailable("The sample video \"\(name).\(fileExtension)\" is missing from the app bundle.")
            return
        }

        configureAudioSession()

        let item = AVPlayerItem(url: url)
        let newPlayer = AVPlayer(playerItem: item)
        state = .loading
        observe(newPlayer, item: item)
        player = newPlayer
    }

    /// Pauses, releases the player and observers. Call when leaving the screen.
    func stop() {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil
        cancellables.removeAll()
        isPlaying = false
        state = .idle
        deactivateAudioSession()
    }

    func retry() {
        stop()
        prepare()
    }

    // MARK: - Controls

    func togglePlayback() {
        guard state == .ready else { return }
        isPlaying ? pause() : play()
    }

    func play() {
        guard state == .ready else { return }
        player?.play()
    }

    func pause() {
        player?.pause()
    }

    // MARK: - Private

    private func observe(_ player: AVPlayer, item: AVPlayerItem) {
        item.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .readyToPlay:
                    self.state = .ready
                case .failed:
                    let message = item.error?.localizedDescription ?? "Playback failed."
                    self.logger.error("Playback failed: \(message)")
                    self.state = .failed(message)
                case .unknown:
                    break
                @unknown default:
                    break
                }
            }
            .store(in: &cancellables)

        player.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                // `.waitingToPlayAtSpecifiedRate` still means "user pressed play".
                self?.isPlaying = (status != .paused)
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: AVPlayerItem.didPlayToEndTimeNotification, object: item)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                // Rewind so the next tap on play replays from the start.
                self?.player?.seek(to: .zero)
                self?.player?.pause()
            }
            .store(in: &cancellables)
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .moviePlayback)
            try session.setActive(true)
        } catch {
            logger.error("Audio session setup failed: \(error.localizedDescription)")
        }
    }

    private func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            logger.error("Audio session deactivation failed: \(error.localizedDescription)")
        }
    }
}
