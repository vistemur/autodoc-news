import Foundation

protocol WebViewModelInput {
    var url: URL { get }
}

class WebViewModel {
    
    let url: URL
    private let viewModel: WebViewModelOutput
    
    init(viewModel: WebViewModelOutput, url: URL) {
        self.viewModel = viewModel
        self.url = url
    }
}

// MARK: - WebViewModelInput
extension WebViewModel: WebViewModelInput {
}
