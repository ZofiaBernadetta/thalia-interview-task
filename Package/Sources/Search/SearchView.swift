import CustomViews
import Networking
import SwiftUI

public struct SearchView: View {
    @ObservedObject var model: SearchViewModel

    public init(model: SearchViewModel) {
        self.model = model
    }

    public var body: some View {
        NavigationStack {
            Group {
                if model.tracks.isEmpty && model.loadingState != .loading {
                    EmptyContentView {
                        if model.searchQuery.isEmpty {
                            Image(systemName: "magnifyingglass")
                            Text("Search Tracks")
                        } else if model.loadingState == .none {
                            Text("No results for “\(model.searchQuery)”.")
                        } else if model.loadingState == .failure {
                            Image(systemName: "exclamationmark.triangle")
                            Text("Failed to load results.")
                        }
                    }
                    .padding()
                } else {
                    list
                }
            }
            .navigationTitle("Search")
            .scrollDismissesKeyboard(.interactively)
            .searchable(
                text: $model.searchQuery,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search"
            )
            .disableAutocorrection(true)
        }
    }

    private var list: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(model.tracks) { track in
                    NavigationLink {
                        TrackDetailView(track: track)
                    } label: {
                        TrackRow(track: track)
                    }
                }

                if model.shouldShowLoadingSection {
                    LoadingProgressSection(
                        loadingState: model.loadingState,
                        onRetry: { model.scrolledToBottom() }
                    )
                    .onAppear {
                        model.scrolledToBottom()
                    }
                }
            }
            .onChange(of: model.searchQuery) { _ in
                guard let id = model.tracks.first?.id else { return }
                proxy.scrollTo(id)
            }
        }
    }
}

private struct LoadingProgressSection: View {
    var loadingState: SearchViewModel.LoadingState
    var onRetry: () -> Void

    var body: some View {
        Section {
            HStack(spacing: 8) {
                switch loadingState {
                case .none:
                    Color.clear.frame(height: 1)
                case .loading:
                    ProgressView()
                    Text("Loading")
                case .failure:
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.accentColor)
                    Button("Failed to load results. Tap to retry.", action: onRetry)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .listRowBackground(Color.clear)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        let model = SearchViewModel(
            apiClient: MockAPIClient(),
            country: "de"
        )

        SearchView(model: model)
            .onAppear {
                model.tracks = [
                    .init(
                        trackId: 1,
                        trackName: "Track Name",
                        artistName: "Artist Name",
                        collectionName: "Album Name",
                        releaseDate: .init(timeIntervalSinceReferenceDate: 0),
                        primaryGenreName: "Genre",
                        trackViewUrl: URL(string: "https://music.apple.com")!
                    ),
                    .init(
                        trackId: 2,
                        trackName: "Track Name 2",
                        artistName: "Artist Name 2",
                        collectionName: "Album Name 2",
                        releaseDate: .init(timeIntervalSinceReferenceDate: 0),
                        primaryGenreName: "Genre",
                        trackViewUrl: URL(string: "https://music.apple.com")!
                    )
                ]
            }
    }
}
