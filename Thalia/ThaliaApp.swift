//
//  ThaliaApp.swift
//  Thalia
//
//  Created by Zofia Drabek on 29.05.23.
//

import Networking
import Search
import SwiftUI

@MainActor
private final class Dependencies {
    let apiClient: APIClient
    let country: String
    let searchViewModel: SearchViewModel

    init() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let configuration = try? AppConfiguration.loadFromBundle(using: decoder) else {
            fatalError("Unable to load configuration.")
        }

        self.apiClient = APIClient(baseURL: configuration.baseURL, decoder: decoder)
        self.country = configuration.country
        self.searchViewModel = SearchViewModel(apiClient: apiClient, country: country)
    }
}

@main
@MainActor
struct ThaliaApp: App {
    @State private var dependencies = Dependencies()

    var body: some Scene {
        WindowGroup {
            SearchView(model: dependencies.searchViewModel)
        }
    }
}
