import UIKit

extension UIImage {
    
    func resize(to newSize: CGSize) -> UIImage {
        let newSize = sizeKeepingAspectRatio(to: newSize)
        
        guard size != newSize else {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? self
    }
    
    private func sizeKeepingAspectRatio(to targetSize: CGSize) -> CGSize {
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let lowestRatio = min(widthRatio, heightRatio)
        
        return CGSize(width: size.width * lowestRatio, height: size.height * lowestRatio)
    }
}
