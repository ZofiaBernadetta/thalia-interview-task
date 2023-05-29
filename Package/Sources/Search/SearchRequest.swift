import CoreModel
import Networking

struct SearchRequest: APIRequest {
    var term: String
    var country: String
    var media: String = "music"
    var limit: Int
    var offset: Int = 0

    let endpoint = "/search"
    let method = "GET"
    var queryParameters: [String : String] {
        [
            "term": term,
            "country": country,
            "media": media,
            "limit": String(limit),
            "offset": String(offset),
        ]
    }

    struct Response: Decodable {
        var results: [Track]
    }
}
