import Foundation

/// Abstraction over wherever the feed comes from.
/// A real app would provide a `RemoteFeedService` (URLSession) that conforms to this.
protocol FeedServiceProtocol {
    func fetchFeed() async throws -> [FounderVideo]
}

enum FeedServiceError: LocalizedError {
    case networkUnavailable

    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "We couldn't reach the server. Check your connection and try again."
        }
    }
}

/// Mock implementation with simulated latency and selectable scenarios,
/// so loading / empty / error states can all be demonstrated.
struct MockFeedService: FeedServiceProtocol {

    enum Scenario {
        case success, empty, failure
    }

    var scenario: Scenario = .success
    var latency: Duration = .milliseconds(900)

    func fetchFeed() async throws -> [FounderVideo] {
        try await Task.sleep(for: latency)

        switch scenario {
        case .success: return Self.sampleItems
        case .empty:   return []
        case .failure: throw FeedServiceError.networkUnavailable
        }
    }
}

extension MockFeedService {
    /// Fictional founders and stories. The last item has no video on purpose
    /// to exercise the "video unavailable" fallback.
    static let sampleItems: [FounderVideo] = [
        FounderVideo(
            id: "founder-001",
            title: "Our first 100 customers, zero ad spend",
            founderName: "Aarav Mehta",
            founderRole: "Co-founder & CEO, Looply",
            summary: "How cold DMs, community answers and a public changelog brought in our first hundred paying customers.",
            category: "Growth",
            duration: 8,
            videoFileName: "sample1",
            thumbnailStyle: .sunrise,
            thumbnailSymbol: "chart.line.uptrend.xyaxis"
        ),
        FounderVideo(
            id: "founder-002",
            title: "Pivoting after 14 months",
            founderName: "Sara Lindqvist",
            founderRole: "Founder, Nordhaus Labs",
            summary: "The three signals that told us our original idea was wrong, and how we told the team.",
            category: "Strategy",
            duration: 8,
            videoFileName: "sample2",
            thumbnailStyle: .ocean,
            thumbnailSymbol: "arrow.triangle.branch"
        ),
        FounderVideo(
            id: "founder-003",
            title: "Hiring your first engineer as a non-technical founder",
            founderName: "Diego Alvarez",
            founderRole: "CEO, Fieldnote",
            summary: "What to look for, how to run a paid trial project, and the red flags we ignored the first time.",
            category: "Hiring",
            duration: 8,
            videoFileName: "sample3",
            thumbnailStyle: .forest,
            thumbnailSymbol: "person.2.fill"
        ),
        FounderVideo(
            id: "founder-004",
            title: "Pricing mistakes that cost us a year",
            founderName: "Priya Nair",
            founderRole: "Co-founder, Ledgerly",
            summary: "We underpriced for 12 months. Here's the experiment that finally showed us the real willingness to pay.",
            category: "Pricing",
            duration: 8,
            videoFileName: "sample4",
            thumbnailStyle: .violet,
            thumbnailSymbol: "tag.fill"
        ),
        FounderVideo(
            id: "founder-005",
            title: "From side project to seed round",
            founderName: "Tomasz Kowalski",
            founderRole: "Founder, Brightpath",
            summary: "Nights-and-weekends to full-time: the metrics that made investors take a first meeting.",
            category: "Fundraising",
            duration: 8,
            videoFileName: "sample5",
            thumbnailStyle: .ember,
            thumbnailSymbol: "flame.fill"
        ),
        FounderVideo(
            id: "founder-006",
            title: "Why we turned down an acquisition offer",
            founderName: "Mei Tanaka",
            founderRole: "CEO, Orbital Notes",
            summary: "A candid look at the decision framework we used, and what we'd do differently. (Video coming soon.)",
            category: "Leadership",
            duration: 0,
            videoFileName: nil,
            thumbnailStyle: .slate,
            thumbnailSymbol: "building.2.fill"
        )
    ]
}
