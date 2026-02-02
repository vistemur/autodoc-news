import UIKit

class LoaderCollectionViewCell: UICollectionViewListCell {
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        setupActivityIndicatorView()
    }
    
    private func setupActivityIndicatorView() {
        contentView.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: layoutMarginsGuide.centerYAnchor),
        ])
    }
    
    func startActivity() {
        activityIndicatorView.startAnimating()
    }
}
