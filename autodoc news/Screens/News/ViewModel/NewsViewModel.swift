import UIKit
import Combine
import WebKit

protocol NewsViewControllerOutput: UICollectionViewDelegate {
    func viewDidLoad()
}

protocol NewsModelOutput {
}

class NewsViewModel: NSObject {
    
    var model: NewsModelInput!
    weak var view: (NewsViewControllerInput & AnyObject)!
        
    private let newsService: NewsService
    private var newsListener: AnyCancellable?
    private let webViewProvider: WebViewProvider
    
    var oldTopIndex: IndexPath?

    init(newsService: NewsService,
         webViewProvider: WebViewProvider) {
        self.newsService = newsService
        self.webViewProvider = webViewProvider
    }
}

// MARK: - NewsViewControllerOutput
extension NewsViewModel: NewsViewControllerOutput {
    
    func viewDidLoad() {
        model.initDataSource(collectionView: view.collectionView)
        Task {
            await newsService.requestNews()
        }
        
        newsListener = newsService.$news.sink { [weak self] news in
            guard let self else {
                return
            }
            
            self.model.setNews(news, isMaximum: self.newsService.totalNews <= news.count)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let id = model.idForCell(at: indexPath.row)
        if let item = newsService.news.first(where: { $0.id == id} ),
           let url = item.fullUrl {
            let webViewViewController = WebViewViewController.assemble(url: url, webViewProvider: webViewProvider)
            view?.pushViewController(webViewViewController, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? NewsCollectionViewCell {
            cell.data?.imageHolder?.requestImage(dimension: .init(width: 300, height: 150))
        }
        
        if indexPath.row >= model.itemsCount - NewsViewModelValues.newsOffsetForRequest &&
            newsService.totalNews > newsService.news.count {
            Task {
                await newsService.requestNews()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? NewsCollectionViewCell {
            cell.data?.imageHolder?.loadingState = .markedForDeletion
            //cell.data?.imageHolder?.clear()
        }
    }
}


// MARK: - NewsModelOutput
extension NewsViewModel: NewsModelOutput {
}

fileprivate enum NewsViewModelValues {
    static let newsOffsetForRequest = 5
}
