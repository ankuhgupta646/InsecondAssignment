import Foundation

/// Drives the feed screen. Owns loading state and exposes what the view needs to render.
@MainActor
final class FeedViewModel: ObservableObject {

    enum ViewState: Equatable {
        case idle
        case loading
        case loaded
        case empty
        case failed(String)
    }

    @Published private(set) var videos: [FounderVideo] = []
    @Published private(set) var state: ViewState = .idle

    private let service: FeedServiceProtocol
    private var isFetching = false

    init(service: FeedServiceProtocol) {
        self.service = service
    }

    /// Initial load, retry and pull-to-refresh all go through here.
    func loadFeed() async {
        guard !isFetching else { return }
        isFetching = true
        defer { isFetching = false }

        // Only show the full-screen spinner when there is nothing on screen yet.
        if videos.isEmpty { state = .loading }

        do {
            let items = try await service.fetchFeed()
            videos = items
            state = items.isEmpty ? .empty : .loaded
        } catch is CancellationError {
            // e.g. pull-to-refresh interrupted: fall back to whatever we had.
            state = videos.isEmpty ? .idle : .loaded
        } catch {
            // Keep existing content on a failed refresh; only show the error screen when empty.
            if videos.isEmpty {
                state = .failed(error.localizedDescription)
            }
        }
    }
}
