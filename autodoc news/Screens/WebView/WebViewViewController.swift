import UIKit
import WebKit

protocol WebViewViewControllerInput {
    func setUrl(request: URLRequest)
}

class WebViewViewController: UIViewController {
    
    // MARK: - UI properties

    var viewModel: WebViewViewControllerOutput?
    private var webView: WKWebView?
        
    // MARK: - life cycle

    override func viewDidLoad() {
        setup()
        viewModel?.viewDidLoad()
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - setup
    private func setup() {
        setupView()
        setupWebView()
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
    }
    
    private func setupWebView() {
        guard let webView = viewModel?.getWebView() else {
            return
        }
        
        self.webView = webView
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
}

// MARK: - WebViewViewControllerInput
extension WebViewViewController: WebViewViewControllerInput {
    
    func setUrl(request: URLRequest) {
        webView?.load(request)
    }
}

// MARK: - Assemble
extension WebViewViewController {
    
    static func assemble(url: URL, webViewProvider: WebViewProvider) -> UIViewController {
        let view = WebViewViewController()
        let viewModel = WebViewViewModel(webViewProvider: webViewProvider)
        let model = WebViewModel(viewModel: viewModel, url: url)
        
        view.viewModel = viewModel
        viewModel.view = view
        viewModel.model = model
        return view
    }
}
