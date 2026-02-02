import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let appServices = AppServices()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        
        appServices.webViewProvider.preload()
        Task {
            await appServices.imageDiskCacheService.loadInfo()
        }
                
        let window = UIWindow(windowScene: windowScene)
        let viewController = NewsViewController.assemble(newsService: appServices.newsService, webViewProvider: appServices.webViewProvider)
        let navigationController = UINavigationController(rootViewController: viewController)
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        appServices.imageDiskCacheService.saveInfo()
    }
}
