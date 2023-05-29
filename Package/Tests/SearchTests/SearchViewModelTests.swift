import CoreModel
import Essentials
import Networking
@testable import Search
import XCTest

@MainActor
final class SearchViewModelTests: XCTestCase {
    var apiClient: MockAPIClient!
    var model: SearchViewModel!

    override func setUp() async throws {
        try await super.setUp()
        apiClient = MockAPIClient()
        model = SearchViewModel(apiClient: apiClient, country: "abc")
    }

    override func tearDown() async throws {
        try await super.tearDown()
        apiClient = nil
        model = nil
    }

    func testInitialState() {
        XCTAssertEqual(model.loadingState, .none)
        XCTAssertEqual(model.searchQuery, "")
        XCTAssertEqual(model.shouldShowLoadingSection, false)
        XCTAssertEqual(model.tracks, [])
    }

    func testSearchStringChangedWithFewerNumberOfResponsesThanLimit() async {
        model.searchQuery = "query"
        await apiClient.waitUntilNextRequest()

        XCTAssertEqual(model.loadingState, .loading)
        XCTAssertEqual(model.searchQuery, "query")
        XCTAssertEqual(model.shouldShowLoadingSection, true)
        XCTAssertEqual(model.tracks, [])

        apiClient.requestContinuation?.resume(
            returning: SearchRequest.Response(results: (0..<2).map(mockTracks))
        )
        _ = await model.taskHandle?.result

        XCTAssertEqual(model.loadingState, .none)
        XCTAssertEqual(model.searchQuery, "query")
        XCTAssertEqual(model.shouldShowLoadingSection, false)
        XCTAssertEqual(model.tracks, (0..<2).map(mockTracks))
    }

    func testSearchStringChangedWithNumberOfResponsesEqualToLimit() async {
        model.searchQuery = "query"
        await apiClient.waitUntilNextRequest()

        XCTAssertEqual(model.loadingState, .loading)
        XCTAssertEqual(model.searchQuery, "query")
        XCTAssertEqual(model.shouldShowLoadingSection, true)
        XCTAssertEqual(model.tracks, [])

        apiClient.requestContinuation?.resume(
            returning: SearchRequest.Response(results: (0..<25).map(mockTracks))
        )
        _ = await model.taskHandle?.result

        XCTAssertEqual(model.loadingState, .none)
        XCTAssertEqual(model.searchQuery, "query")
        XCTAssertEqual(model.shouldShowLoadingSection, true)
        XCTAssertEqual(model.tracks, (0..<25).map(mockTracks))
    }

    func testSearchQuery() async {
        model.searchQuery = "query"
        await apiClient.waitUntilNextRequest()
        apiClient.requestContinuation?.resume(
            returning: SearchRequest.Response(results: (0..<25).map(mockTracks))
        )
        _ = await model.taskHandle?.result

        guard let request = apiClient.latestRequest as? SearchRequest else {
            XCTFail("Unexpected search request.")
            return
        }

        XCTAssertEqual(request.term, "query")
        XCTAssertEqual(request.country, "abc")
        XCTAssertEqual(request.media, "music")
        XCTAssertEqual(request.limit, 25)
        XCTAssertEqual(request.offset, 0)

        model.scrolledToBottom()
        await apiClient.waitUntilNextRequest()
        apiClient.requestContinuation?.resume(
            returning: SearchRequest.Response(results: (25..<50).map(mockTracks))
        )
        _ = await model.taskHandle?.result

        guard let request = apiClient.latestRequest as? SearchRequest else {
            XCTFail("Unexpected search request.")
            return
        }

        XCTAssertEqual(request.term, "query")
        XCTAssertEqual(request.country, "abc")
        XCTAssertEqual(request.media, "music")
        XCTAssertEqual(request.limit, 25)
        XCTAssertEqual(request.offset, 25)

        model.scrolledToBottom()
        await apiClient.waitUntilNextRequest()
        apiClient.requestContinuation?.resume(
            returning: SearchRequest.Response(results: (50..<75).map(mockTracks))
        )
        _ = await model.taskHandle?.result

        guard let request = apiClient.latestRequest as? SearchRequest else {
            XCTFail("Unexpected search request.")
            return
        }

        XCTAssertEqual(request.term, "query")
        XCTAssertEqual(request.country, "abc")
        XCTAssertEqual(request.media, "music")
        XCTAssertEqual(request.limit, 25)
        XCTAssertEqual(request.offset, 50)
    }

    func testScrolledToBottom() async {
        model.searchQuery = "query"

        await apiClient.waitUntilNextRequest()
        apiClient.requestContinuation?.resume(
            returning: SearchRequest.Response(results: (0..<25).map(mockTracks))
        )
        _ = await model.taskHandle?.result

        XCTAssertEqual(model.loadingState, .none)
        XCTAssertEqual(model.searchQuery, "query")
        XCTAssertEqual(model.shouldShowLoadingSection, true)
        XCTAssertEqual(model.tracks, (0..<25).map(mockTracks))

        model.scrolledToBottom()

        await apiClient.waitUntilNextRequest()
        apiClient.requestContinuation?.resume(
            returning: SearchRequest.Response(results: (25..<50).map(mockTracks))
        )
        _ = await model.taskHandle?.result

        XCTAssertEqual(model.loadingState, .none)
        XCTAssertEqual(model.searchQuery, "query")
        XCTAssertEqual(model.shouldShowLoadingSection, true)
        XCTAssertEqual(model.tracks, (0..<50).map(mockTracks))
    }

    func testMultipleCallsToScrolledToBottom() async {
        model.searchQuery = "query"

        await apiClient.waitUntilNextRequest()
        apiClient.requestContinuation?.resume(
            returning: SearchRequest.Response(results: (0..<25).map(mockTracks))
        )
        _ = await model.taskHandle?.result

        XCTAssertEqual(model.loadingState, .none)
        XCTAssertEqual(model.searchQuery, "query")
        XCTAssertEqual(model.shouldShowLoadingSection, true)
        XCTAssertEqual(model.tracks, (0..<25).map(mockTracks))

        model.scrolledToBottom()
        await apiClient.waitUntilNextRequest()

        model.scrolledToBottom()
        XCTAssertEqual(apiClient.hasCanceledRequest.rawValue, false)

        apiClient.requestContinuation?.resume(
            returning: SearchRequest.Response(results: (20..<45).map(mockTracks))
        )
        _ = await model.taskHandle?.result
    }

    func testDuplicateItemsReturnedInResponse() async {
        model.searchQuery = "query"

        await apiClient.waitUntilNextRequest()
        apiClient.requestContinuation?.resume(
            returning: SearchRequest.Response(results: (0..<25).map(mockTracks))
        )
        _ = await model.taskHandle?.result

        XCTAssertEqual(model.loadingState, .none)
        XCTAssertEqual(model.searchQuery, "query")
        XCTAssertEqual(model.shouldShowLoadingSection, true)
        XCTAssertEqual(model.tracks, (0..<25).map(mockTracks))

        model.scrolledToBottom()

        await apiClient.waitUntilNextRequest()
        apiClient.requestContinuation?.resume(
            returning: SearchRequest.Response(results: (20..<45).map(mockTracks))
        )
        _ = await model.taskHandle?.result

        XCTAssertEqual(model.loadingState, .none)
        XCTAssertEqual(model.searchQuery, "query")
        XCTAssertEqual(model.shouldShowLoadingSection, true)
        XCTAssertEqual(model.tracks, (0..<45).map(mockTracks))
    }

    func mockTracks(id: Track.ID) -> Track {
        Track(
            trackId: id,
            trackName: "Name \(id)",
            artistName: "Artist \(id)",
            collectionName: "Collection \(id)",
            releaseDate: Date(timeIntervalSinceReferenceDate: 0),
            primaryGenreName: "Genre \(id)",
            trackViewUrl: URL(string: "https://music.apple.com")!
        )
    }
}

@MainActor
class MockAPIClient: APIClientProtocol {
    var latestRequest: Any?
    var requestContinuation: CheckedContinuation<Any, Error>?
    var hasReceivedRequest = false
    var hasCanceledRequest: SynchronizedStorage<Bool> = .init(rawValue: false)

    private var (stream, streamContinuation) =  {
        var continuation: AsyncStream<Void>.Continuation!
        let stream = AsyncStream { continuation = $0 }
        return (stream, continuation)
    }()

    struct MockAPIClientError: Error {}

    func fetch<T: APIRequest>(_ request: T) async throws -> T.Response {
        requestContinuation?.resume(throwing: MockAPIClientError())
        requestContinuation = nil

        hasReceivedRequest = true
        streamContinuation?.yield()

        latestRequest = request
        let response = try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                requestContinuation = continuation
            }
        } onCancel: { [hasCanceledRequest] in
            hasCanceledRequest.rawValue = true
        }

        requestContinuation = nil
        if let response = response as? T.Response {
            return response
        } else {
            throw MockAPIClientError()
        }
    }

    func waitUntilNextRequest() async {
        if hasReceivedRequest {
            hasReceivedRequest = false
            return
        }

        var iterator = stream.makeAsyncIterator()
        _ = await iterator.next()
        hasReceivedRequest = false
    }
}
