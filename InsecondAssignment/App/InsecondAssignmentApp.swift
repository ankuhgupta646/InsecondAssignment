//
//  InsecondAssignmentApp.swift
//  InsecondAssignment
//
//  Created by Ankush Gupta on 20/10/26.
//

import SwiftUI

@main
struct InsecondAssignmentApp: App {
    /// Composition root: the only place that knows which concrete service is used.
    private let service = MockFeedService(scenario: .fromLaunchArguments())

    var body: some Scene {
        WindowGroup {
            FeedView(viewModel: FeedViewModel(service: service))
        }
    }
}
extension MockFeedService.Scenario {
    /// Add `-mockEmpty` or `-mockFailure` under
    /// Product > Scheme > Edit Scheme > Run > Arguments to preview those states.
    static func fromLaunchArguments(
        _ arguments: [String] = ProcessInfo.processInfo.arguments
    ) -> MockFeedService.Scenario {
        if arguments.contains("-mockEmpty") { return .empty }
        if arguments.contains("-mockFailure") { return .failure }
        return .success
    }
}
