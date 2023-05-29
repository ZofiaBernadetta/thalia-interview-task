import Foundation

public protocol APIClientProtocol {
    func fetch<T: APIRequest>(_ request: T) async throws -> T.Response
}

public final class APIClient: APIClientProtocol {
    let baseURL: URL
    let decoder: JSONDecoder

    public init(baseURL: URL, decoder: JSONDecoder) {
        self.baseURL = baseURL
        self.decoder = decoder
    }

    public func fetch<T: APIRequest>(_ request: T) async throws -> T.Response {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            throw URLError(.badURL)
        }

        components.path = request.endpoint
        components.queryItems = request.queryParameters.map(URLQueryItem.init)
        guard let url = components.url else {
            throw URLError(.badURL)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method
        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard
            let response = response as? HTTPURLResponse,
            200 ..< 300 ~= response.statusCode
        else {
            throw URLError(.badServerResponse)
        }

        return try decoder.decode(T.Response.self, from: data)
    }
}

public class MockAPIClient: APIClientProtocol {
    public init() {}

    public func fetch<T: APIRequest>(_ request: T) async throws -> T.Response {
        throw URLError(.badServerResponse)
    }
}
