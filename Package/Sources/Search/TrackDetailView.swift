import CoreModel
import CustomViews
import SwiftUI

struct TrackDetailView: View {
    var track: Track

    @State private var isSafariViewPresented = false

    var body: some View {
        List {
            Group {
                cover

                VStack {
                    Text(track.artistName)
                        .foregroundStyle(.secondary)

                    Text(track.trackName)
                        .font(.title)
                        .fontWeight(.semibold)

                    if let collectionName = track.collectionName {
                        Text(collectionName)
                    }

                    Text(track.releaseDate, format: .dateTime.year())
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(track.primaryGenreName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
            }
            .listRowBackground(Color.clear)
            .listRowInsets(.init())
            .listRowSeparator(.hidden)
        }
        .fullScreenCover(isPresented: $isSafariViewPresented) {
            SafariView(url: track.trackViewUrl)
        }
        .toolbar {
            Button {
                isSafariViewPresented = true
            } label: {
                Label("Open Web Page", systemImage: "arrow.up.forward.app")
                    .labelStyle(.iconOnly)
            }
        }
        .navigationTitle(track.trackName)
    }

    var cover: some View {
        Group {
            if let url = track.coverImageLargeURL {
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
        .scaledToFill()
        .aspectRatio(1, contentMode: .fit)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.gray, lineWidth: 0.1)
        )
        .shadow(radius: 15)
        .padding(30)
    }
}

struct TrackDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TrackDetailView(
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
        }
    }
}
