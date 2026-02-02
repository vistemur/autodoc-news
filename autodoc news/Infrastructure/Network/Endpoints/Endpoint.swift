import Foundation

protocol Endpoint {
    
    associatedtype Response: Decodable
    var path: String { get }
}

extension Endpoint {
    
    func urlRequest() throws -> URLRequest {
        guard let url = URL(string: path) else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }

        return URLRequest(url: url)
    }
}
