import SwiftUI

struct FeedView: View {

    @StateObject private var viewModel: FeedViewModel

    /// `@autoclosure` ensures the view model is created once, not on every parent re-render.
    init(viewModel: @autoclosure @escaping () -> FeedViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Founder Feed")
                .navigationDestination(for: FounderVideo.self) { video in
                    VideoDetailView(video: video)
                }
        }
        .task { await viewModel.loadFeed() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            LoadingStateView(message: "Loading founder stories…")
        case .empty:
            EmptyStateView(
                title: "No stories yet",
                message: "New founder insights will show up here.",
                actionTitle: "Refresh",
                action: reload
            )
        case .failed(let message):
            ErrorStateView(message: message, retry: reload)
        case .loaded:
            feedList
        }
    }

    private var feedList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.videos) { video in
                    NavigationLink(value: video) {
                        FeedItemCard(video: video)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .refreshable { await viewModel.loadFeed() }
    }

    private func reload() {
        Task { await viewModel.loadFeed() }
    }
}

#Preview("Success") {
    FeedView(viewModel: FeedViewModel(service: MockFeedService(latency: .milliseconds(300))))
}

#Preview("Empty") {
    FeedView(viewModel: FeedViewModel(service: MockFeedService(scenario: .empty, latency: .milliseconds(300))))
}

#Preview("Error") {
    FeedView(viewModel: FeedViewModel(service: MockFeedService(scenario: .failure, latency: .milliseconds(300))))
}
