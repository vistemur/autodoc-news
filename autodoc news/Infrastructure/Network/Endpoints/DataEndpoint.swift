import Foundation

struct DataEndpoint: Endpoint {
    
    typealias Response = Data
    let path: String
    
    init(path: String) {
        self.path = path
    }
}
