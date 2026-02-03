import UIKit
import Combine

class ImageHolder: Hashable, Equatable {
    
    var loadingState: LoadingState
    let path: String
    var lastRequest: Date
    @Published var image: UIImage?
    private let requestImage: (String, CGSize) async -> UIImage?
    var loadingTask: Task<Sendable, Error>?
    
    init(path: String, image: UIImage? = nil, lastRequest: Date = .now, requestImage: @escaping (String, CGSize) async -> UIImage?) {
        self.path = path
        self.image = image
        self.lastRequest = lastRequest
        self.requestImage = requestImage
        self.loadingState = .notLoaded
    }
    
    func requestImage(dimension: CGSize) {
        lastRequest = .now
        
        if image != nil {
            return
        }
        
        loadingState = .loading
        let path = path
        loadingTask = Task {
            if let image = await requestImage(path, dimension) {
                if self.loadingState != .cleared {
                    self.image = image
                    self.loadingState = .loaded
                }
            } else {
                if self.loadingState != .cleared {
                    self.loadingState = .notLoaded
                }
            }
            return
        }
    }
    
    func clear() {
        image = nil
        loadingTask?.cancel()
        loadingTask = nil
        self.loadingState = .cleared
    }
    
    static func == (lhs: ImageHolder, rhs: ImageHolder) -> Bool {
        lhs.path == rhs.path
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
    
    enum LoadingState {
        case loading
        case loaded
        case notLoaded
        case cleared
        case markedForDeletion
    }
}
