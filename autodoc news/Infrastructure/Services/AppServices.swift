import Foundation

class AppServices {
    lazy var networkService: NetworkService = { .init() }()
    lazy var webViewProvider: WebViewProvider = { .init() }()
    lazy var imageDiskCacheService: ImageDiskCacheService = { .init() }()
    lazy var imageService: ImageService = { .init(networkService: networkService,
                                                  imageDiskCacheService: imageDiskCacheService) }()
    lazy var newsService: NewsService = { .init(networkService: networkService, imageService: imageService) }()
}
