import Foundation

public protocol APIRequest {
    associatedtype Response: Decodable
    var endpoint: String { get }
    var queryParameters: [String: String] { get }
    var method: String { get }
}
