import Foundation

struct NewsEndpoint: Endpoint {
    
    typealias Response = NewsEndpointResponse
    let path: String
    
    init(page: Int, elements: Int) {
        path = "https://webapi.autodoc.ru/api/news/\(page)/\(elements)"
    }
}

struct NewsEndpointResponse: Decodable {
    
    let news: [News]
    let totalCount: Int
    
    struct News: Decodable {
        
        let id: Int
        let title: String
        let url: String
        let fullUrl: String
        let description: String
        let publishedDate: String
        let titleImageUrl: String?
        let categoryType: String
    }
}
