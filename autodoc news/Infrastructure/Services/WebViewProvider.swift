import WebKit

class WebViewProvider {
    
    let webViewQueue = DispatchQueue(label: "WebViewProviderQueue")
    
    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        return webView
    }()
    
    func preload() {
        DispatchQueue.main.async {
            self.webView.loadHTMLString("", baseURL: nil)
        }
    }
}
