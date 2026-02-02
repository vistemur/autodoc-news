import UIKit

protocol NewsViewControllerInput {
    var collectionView: UICollectionView { get }
    func pushViewController(_ viewController: UIViewController, animated: Bool)
}

class NewsViewController: UIViewController {
    
    // MARK: - UI properties

    var viewModel: NewsViewControllerOutput!
    
    lazy var collectionView: UICollectionView = {
        let layout = NewsCollectionViewLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.selfSizingInvalidation = .enabledIncludingConstraints
        collectionView.delegate = viewModel
        return collectionView
    }()
    
    // MARK: - life cycle
    override func viewDidLoad() {
        viewModel.viewDidLoad()
        setup()
        super.viewDidLoad()
    }
    
    var oldTopVisibleItemIndexPath: IndexPath?
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)

        if let topVisibleItemIndexPath = collectionView.indexPathsForVisibleItems.min() {
            self.oldTopVisibleItemIndexPath = topVisibleItemIndexPath
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let oldTopVisibleItemIndexPath {
            self.oldTopVisibleItemIndexPath = nil
            collectionView.scrollToItem(at: oldTopVisibleItemIndexPath, at: .top, animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - setup
    private func setup() {
        setupView()
        setupCollectionView()
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
}

// MARK: - NewsViewControllerInput
extension NewsViewController: NewsViewControllerInput {
    
    func pushViewController(_ viewController: UIViewController, animated: Bool) {
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(viewController, animated: animated)
        }
    }
}

// MARK: - Assemble
extension NewsViewController {
    
    static func assemble(newsService: NewsService, webViewProvider: WebViewProvider) -> UIViewController {
        let view = NewsViewController()
        let viewModel = NewsViewModel(newsService: newsService, webViewProvider: webViewProvider)
        let model = NewsModel(viewModel: viewModel)
        
        view.viewModel = viewModel
        viewModel.view = view
        viewModel.model = model
        return view
    }
}
