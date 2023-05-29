import CoreModel
import XCTest

final class TrackTests: XCTestCase {
    let testTrack = Track(
        trackId: 123,
        trackName: "Name",
        artistName: "Artist",
        collectionName: "Collection",
        releaseDate: Date(timeIntervalSinceReferenceDate: 0),
        primaryGenreName: "Genre",
        trackViewUrl: URL(string: "https://music.apple.com")!,
        artworkUrl100: URL(string: "https://music.apple.com/artwork")!
    )

    func testIdentity() {
        XCTAssertEqual(testTrack.id, 123)
    }

    func testCoverImageThumbnailURL() {
        var testTrack = testTrack
        XCTAssertEqual(testTrack.coverImageThumbnailURL, testTrack.artworkUrl100)

        let testURL1 = URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/68/19/43/68194388-efa7-3afe-8a15-a4c3eebef1f6/886445915211.jpg/100x100bb.jpg")
        testTrack.artworkUrl100 = testURL1
        XCTAssertEqual(testTrack.coverImageThumbnailURL, testURL1)

        let testURL2 = URL(string: "http://a1.itunes.apple.com/r10/Music/3b/6a/33/mzi.qzdqwsel.100x100-75.jpg")
        testTrack.artworkUrl100 = testURL2
        XCTAssertEqual(testTrack.coverImageThumbnailURL, testURL2)
    }

    func testCoverImageLargeURL() {
        var testTrack = testTrack
        XCTAssertEqual(testTrack.coverImageLargeURL, testTrack.artworkUrl100)

        let testURL1 = URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/68/19/43/68194388-efa7-3afe-8a15-a4c3eebef1f6/886445915211.jpg/100x100bb.jpg")
        testTrack.artworkUrl100 = testURL1
        XCTAssertEqual(testTrack.coverImageLargeURL?.absoluteString, "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/68/19/43/68194388-efa7-3afe-8a15-a4c3eebef1f6/886445915211.jpg/600x600bb.jpg")

        let testURL2 = URL(string: "http://a1.itunes.apple.com/r10/Music/3b/6a/33/mzi.qzdqwsel.100x100-75.jpg")
        testTrack.artworkUrl100 = testURL2
        XCTAssertEqual(testTrack.coverImageLargeURL?.absoluteString, "http://a1.itunes.apple.com/r10/Music/3b/6a/33/mzi.qzdqwsel.600x600-75.jpg")
    }
}
