import UIKit
import Combine

class NewsService {
    
    @Published var news: [News] = []
    private(set) var totalNews: Int = 1
        
    private let networkService: NetworkService
    private let imageService: ImageService
    
    private var nextPage: Int = 1
    private var pagesOffset: Int = 0
    private let queue = DispatchQueue(label: "NewsServiceQueue")
    private var loadedPages = Set<Int>()
    
    init(networkService: NetworkService,
         imageService: ImageService) {
        self.networkService = networkService
        self.imageService = imageService
    }
    
    func requestNews() async {
        var allowed = true
        queue.sync {
            if loadedPages.contains(nextPage) {
                allowed = false
            } else {
                loadedPages.insert(nextPage)
            }
        }
        
        guard allowed else {
            return
        }
        
        if let newNews = await requestNews(page: nextPage, amount: NewsServiceValues.newsPerPage) {
            news.append(contentsOf: newNews)
            nextPage += 1
        } else {
            queue.async {
                self.loadedPages.remove(self.nextPage)
            }
        }
    }

    private func requestNews(page: Int, amount: Int) async -> [News]? {
        guard let newsResponse = await networkService.request(endpoint: NewsEndpoint(page: page, elements: amount)) else {
            return nil
        }
        
        totalNews = newsResponse.totalCount
        let news = newsResponse.news.map { [weak self] response in

            let imageHolder: ImageHolder?
            if let imageUrl = response.titleImageUrl {
                imageHolder = self?.imageService.image(path: imageUrl)
            } else {
                imageHolder = nil
            }
            
            let answer = News(id: response.id, title: response.title, description: response.description, imagePath: response.titleImageUrl, imageHolder: imageHolder, fullUrl: URL(string: response.fullUrl))
            return answer
        }
        return news
    }
}

class News {
    
    let id: Int
    let title: String
    let description: String
    let imagePath: String?
    let imageHolder: ImageHolder?
    let fullUrl: URL?
    var hasImage: Bool { imagePath != nil }
    
    init(id: Int, title: String, description: String, imagePath: String?, imageHolder: ImageHolder?, fullUrl: URL?) {
        self.id = id
        self.title = title
        self.description = description
        self.imagePath = imagePath
        self.imageHolder = imageHolder
        self.fullUrl = fullUrl
    }
}

fileprivate enum NewsServiceValues {
    static let newsPerPage = 15
}
