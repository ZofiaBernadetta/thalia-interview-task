import Foundation

public protocol LoadableFromBundle: Decodable {
    static func loadFromBundle(using decoder: JSONDecoder) throws -> Self
}

public extension LoadableFromBundle {
    static func loadFromBundle(using decoder: JSONDecoder) throws -> Self {
        let fileName = String(describing: Self.self)
        guard
            let url = Bundle.main.url(
                forResource: fileName,
                withExtension: "json"
            )
        else {
            throw URLError(.fileDoesNotExist)
        }

        let data = try Data(contentsOf: url)
        return try decoder.decode(Self.self, from: data)
    }
}
