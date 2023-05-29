import CoreModel
import SwiftUI

struct TrackRow: View {
    var track: Track

    var body: some View {
        HStack(spacing: 8) {
            cover

            VStack(alignment: .leading) {
                Text(track.artistName)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(track.trackName)

                if let collectionName = track.collectionName {
                    Text(collectionName)
                        .font(.caption)
                }
            }
            .lineLimit(1)
        }
    }

    var cover: some View {
        Group {
            if let url = track.coverImageThumbnailURL {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable()
                    } else if phase.error != nil {
                        Color.gray
                    } else {
                        ZStack {
                            Color.gray
                            ProgressView()
                        }
                    }
                }
            } else {
                Color.gray
            }
        }
        .frame(width: 50, height: 50)
        .mask(Circle())
        .overlay {
            Circle()
            .stroke(.gray.opacity(0.1))
        }
    }
}

struct TrackRow_Previews: PreviewProvider {
    static var previews: some View {
        TrackRow(
            track: .init(
                trackId: 1,
                trackName: "Track Name",
                artistName: "Artist Name",
                collectionName: "Album Name",
                releaseDate: .init(timeIntervalSinceReferenceDate: 0),
                primaryGenreName: "Genre",
                trackViewUrl: URL(string: "https://music.apple.com")!
            )
        )
        .frame(width: 300, alignment: .leading)
    }
}
