import WebKit

protocol WebViewViewControllerOutput: WKUIDelegate {
    func viewDidLoad()
    func getWebView() -> WKWebView
}

protocol WebViewModelOutput {
}

class WebViewViewModel: NSObject {
    
    var model: WebViewModelInput?
    weak var view: (WebViewViewControllerInput & AnyObject)?
    private let webViewProvider: WebViewProvider
    
    init(webViewProvider: WebViewProvider) {
        self.webViewProvider = webViewProvider
    }
}

// MARK: - WebViewViewControllerOutput
extension WebViewViewModel: WebViewViewControllerOutput {
    
    func getWebView() -> WKWebView {
        webViewProvider.webView
    }
    
    func viewDidLoad() {
        guard let url = model?.url else {
            return
        }
        
        let request = URLRequest(url: url)
        view?.setUrl(request: request)
    }
}

// MARK: - WebViewModelOutput
extension WebViewViewModel: WebViewModelOutput {
}
