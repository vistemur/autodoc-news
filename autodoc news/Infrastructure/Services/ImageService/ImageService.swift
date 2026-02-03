import UIKit
import Combine

class ImageService {
    
    let networkService: NetworkService
    let imageDiskCacheService: ImageDiskCacheService
    var imageHolders = [String: ImageHolder]()
    var imageLoaders = Set<String>()
    var requestsSinceClean = 0
    
    init(networkService: NetworkService,
         imageDiskCacheService: ImageDiskCacheService) {
        self.networkService = networkService
        self.imageDiskCacheService = imageDiskCacheService
    }
    
    func image(path: String) -> ImageHolder {
        let requestImage: (String, CGSize) async -> UIImage? = { [weak self] imagePath, dimension in
            guard let self else {
                return nil
            }
            
            requestsSinceClean += 1
            if requestsSinceClean >= ImageServiceValues.cleanCycle {
                Task {
                    self.removeOldestImages()
                }
                requestsSinceClean = 0
            }
            
            if imageLoaders.contains(path) {
                if imageHolders[path]?.loadingState == .cleared {
                    imageLoaders.remove(path)
                }
                return nil
            }
            
            if self.imageLoaders.count > ImageServiceValues.maxLoaders {
                Task {
                    self.removeOldestLoaders()
                }
            }
            
            if imageHolders[path]?.loadingState == .markedForDeletion {
                return nil
            }
            
            var image: UIImage?
            imageLoaders.insert(path)
            if let savedImage = imageHolders[path]?.image {
                image = savedImage
                imageLoaders.remove(path)
            } else if self.imageDiskCacheService.contains(path: path) {
                if let imageHolder = self.imageHolders[path] {
                    self.imageDiskCacheService.get(imageHolder: imageHolder) {
                        self.imageLoaders.remove(path)
                    }
                }
            } else if let loadedImage = await self.downloadImage(from: path) {
                let scaledImage = loadedImage.resize(to: dimension)
                self.cache(image: scaledImage, path: path)
                image = scaledImage
                imageLoaders.remove(path)
            }
            return image
        }
        
        let imageHolder = ImageHolder(path: path, requestImage: requestImage)
        
        imageHolders[path] = imageHolder
        
        return imageHolder
    }
    
    private func cache(image: UIImage, path: String) {
        Task {
            await self.imageDiskCacheService.set(path: path, image: image)
        }
    }
    
    private func downloadImage(from path: String) async -> UIImage? {
        guard let imageData = await downloadImageData(from: path) else {
            return nil
        }
        
        return UIImage(data: imageData)
    }
    
    private func downloadImageData(from path: String) async -> Data? {
        await networkService.requestData(endpoint: DataEndpoint(path: path))
    }
    
    private func removeOldestLoaders() {
        guard imageLoaders.count > ImageServiceValues.maxLoaders else {
            return
        }
        
        let loadingImageHolders = imageLoaders.compactMap({ imageHolders[$0] })
        let sorted = loadingImageHolders.sorted(by: { $0.lastRequest.compare($1.lastRequest).rawValue == -1 })
        let deleting = sorted.prefix(sorted.count - ImageServiceValues.maxLoaders)
        
        for imageHolder in deleting {
            imageLoaders.remove(imageHolder.path)
            imageHolder.clear()
        }
    }
    
    private func removeOldestImages() {
        let filtered = imageHolders.filter({ $0.value.loadingState == .markedForDeletion || $0.value.loadingState == .loaded })
        let delete = ImageServiceValues.maxCachedImages
        if filtered.count < delete {
            return
        }
        
        let deleting = filtered.sorted(by: { $0.value.lastRequest.compare($1.value.lastRequest).rawValue == -1 }).prefix(filtered.count - delete)
        
        for (path, imageHolder) in deleting {
            imageLoaders.remove(path)
            imageHolder.clear()
        }
    }
}

fileprivate enum ImageServiceValues {
    static let cleanCycle = 10
    static let maxLoaders = 50
    static let maxCachedImages = 100
}
