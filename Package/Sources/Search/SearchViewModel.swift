import Combine
import CoreModel
import Networking

@MainActor
public final class SearchViewModel: ObservableObject {
    enum LoadingState {
        case none
        case loading
        case failure
    }

    @Published var searchQuery = "" {
        didSet {
            loadTracks(appendResults: false)
        }
    }

    @Published var loadingState: LoadingState = .none
    @Published var tracks = [Track]()
    @Published var shouldShowLoadingSection = false

    private let apiClient: any APIClientProtocol
    private let country: String
    private var latestRequest: SearchRequest?
    private var latestOffset = 0
    var taskHandle: Task<Void, Never>?

    public init(apiClient: any APIClientProtocol, country: String) {
        self.apiClient = apiClient
        self.country = country
    }

    func scrolledToBottom() {
        guard latestRequest?.term != searchQuery || latestRequest?.offset != tracks.count else {
            return
        }

        loadTracks(appendResults: true)
    }

    private func loadTracks(appendResults: Bool = true) {
        if loadingState == .loading {
            taskHandle?.cancel()
            taskHandle = nil
            loadingState = .none
        }

        if searchQuery.isEmpty {
            latestRequest = nil
            tracks = []
            shouldShowLoadingSection = false
            latestOffset = 0
            return
        }

        let limit = 25
        let offset = appendResults ? latestOffset + limit : 0
        let request = SearchRequest(
            term: searchQuery,
            country: country,
            limit: limit,
            offset: offset
        )
        let previousRequest = latestRequest
        latestRequest = request

        taskHandle = Task {
            guard !Task.isCancelled else { return }
            loadingState = .loading
            shouldShowLoadingSection = true

            do {
                let response = try await apiClient.fetch(request)
                guard !Task.isCancelled else { return }
                if appendResults {
                    append(tracks: response.results)
                } else {
                    tracks = response.results
                }

                shouldShowLoadingSection = (response.results.count >= limit)
                loadingState = .none
                latestOffset = offset
            } catch {
                guard !Task.isCancelled else { return }
                latestRequest = previousRequest
                loadingState = .failure
            }
        }
    }

    private func append(tracks newTracks: [Track]) {
        var existingTrackIDs = Set(tracks.map(\.id))
        for track in newTracks {
            guard !existingTrackIDs.contains(track.id) else { continue }
            existingTrackIDs.insert(track.id)
            tracks.append(track)
        }
    }
}
