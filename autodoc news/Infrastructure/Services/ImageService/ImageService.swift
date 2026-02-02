import UIKit
import Combine

class ImageService {
    
    let networkService: NetworkService
    let imageDiskCacheService: ImageDiskCacheService
    var imageHolders = [String: ImageHolder]()
    var imageLoaders = Set<String>()
    
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
            
            if imageLoaders.contains(path) {
                if imageHolders[path]?.loadingState == .cleared {
                    imageLoaders.remove(path)
                }
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
    
    private func removeOldestImage(imageHolder: ImageHolder) {
        imageLoaders.remove(imageHolder.path)
        imageHolder.loadingTask?.cancel()
        imageHolder.loadingTask = nil
        imageHolder.loadingState = .cleared
        imageHolder.image = nil
    }
}
