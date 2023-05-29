import Foundation

public struct Track: Hashable, Codable, Identifiable {
    public var trackId: Int
    public var trackName: String
    public var artistName: String
    public var collectionName: String?
    public var releaseDate: Date
    public var primaryGenreName: String
    public var trackViewUrl: URL
    public var artworkUrl100: URL?

    public init(
        trackId: Int,
        trackName: String,
        artistName: String,
        collectionName: String? = nil,
        releaseDate: Date,
        primaryGenreName: String,
        trackViewUrl: URL,
        artworkUrl100: URL? = nil
    ) {
        self.trackId = trackId
        self.trackName = trackName
        self.artistName = artistName
        self.collectionName = collectionName
        self.releaseDate = releaseDate
        self.primaryGenreName = primaryGenreName
        self.trackViewUrl = trackViewUrl
        self.artworkUrl100 = artworkUrl100
    }

    public var id: Int { trackId }

    public var coverImageThumbnailURL: URL? {
        artworkUrl100
    }

    public var coverImageLargeURL: URL? {
        guard let artworkUrl100 else { return nil }
        let imageName = artworkUrl100
            .lastPathComponent
            .replacingOccurrences(of: "100x100", with: "600x600")
        return artworkUrl100
            .deletingLastPathComponent()
            .appending(path: imageName)
    }
}
