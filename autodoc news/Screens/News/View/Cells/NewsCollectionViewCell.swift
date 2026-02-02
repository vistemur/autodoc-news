import UIKit
import Combine

nonisolated struct NewsCollectionViewCellData: Identifiable {
    
    let id: Int
    let title: String
    let description: String
    var imageHolder: ImageHolder?
    var defaultImage: UIImage?
}

class NewsCollectionViewCell: UICollectionViewListCell {
    
    var data: NewsCollectionViewCellData? {
        didSet {
            configure(with: data)
        }
    }
    
    private var imageSubcription: AnyCancellable?
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .systemGray
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private lazy var textHolderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground.withAlphaComponent(0.8)
        view.layer.cornerRadius = 16
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        setupImageView()
        setupTextHolderView()
        setupTitleLabel()
        setupDescriptionLabel()
    }
    
    private func setupImageView() {
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: 8),
            imageView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -16),
            imageView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -8),
        ])
    }
    
    private func setupTextHolderView() {
        imageView.addSubview(textHolderView)
        NSLayoutConstraint.activate([
            textHolderView.topAnchor.constraint(greaterThanOrEqualTo: imageView.topAnchor),
            textHolderView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            textHolderView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            textHolderView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
        ])
    }
    
    private func setupTitleLabel() {
        textHolderView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: textHolderView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: textHolderView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: textHolderView.trailingAnchor, constant: -8),
        ])
    }
    
    private func setupDescriptionLabel() {
        textHolderView.addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: textHolderView.leadingAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: textHolderView.trailingAnchor, constant: -8),
            descriptionLabel.bottomAnchor.constraint(equalTo: textHolderView.bottomAnchor, constant: -4),
        ])
    }
    
    func configure(with data: NewsCollectionViewCellData?) {
        if let data {
            configure(with: data)
        } else {
            configureEmptystate()
        }
    }
    
    private func configureEmptystate() {
        imageSubcription = nil
        DispatchQueue.main.async {
            self.titleLabel.text = ""
            self.descriptionLabel.text = ""
            self.imageView.image = nil
        }
    }
    
    private func configure(with data: NewsCollectionViewCellData) {
        DispatchQueue.main.async {
            self.titleLabel.text = data.title
            self.descriptionLabel.text = data.description
            
            if let defaultImage = data.defaultImage {
                self.imageView.image = defaultImage
            } else {
                self.imageView.image = data.imageHolder?.image
            }
        }
        
        if let imageHolder = data.imageHolder,
           data.defaultImage == nil {
            subscribeToImageHolder(imageHolder: imageHolder)
        }
    }
    
    private func subscribeToImageHolder(imageHolder: ImageHolder) {
        imageSubcription = imageHolder.$image.sink { [weak self] image in
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }
        
        layoutIfNeeded()
        var imageSize = imageView.bounds.size
        if imageSize.width < 100 || imageSize.height < 100 {
            imageSize = .init(width: 300, height: 150)
        }
        
        imageHolder.requestImage(dimension: imageSize)
    }
}
