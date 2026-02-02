import UIKit

protocol NewsModelInput {
    func initDataSource(collectionView: UICollectionView)
    func setNews(_ news: [News], isMaximum: Bool)
    var itemsCount: Int { get }
    func idForCell(at row: Int) -> Int?
}

class NewsModel {
    
    private let viewModel: NewsModelOutput
    private var dataSource: DataSource?
    private var items: [NewsCollectionViewCellData.ID: NewsCollectionViewCellData] = [:]
    
    init(viewModel: NewsModelOutput) {
        self.viewModel = viewModel
    }
}

// MARK: - NewsModelInput
extension NewsModel: NewsModelInput {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, NewsCollectionViewCellData.ID>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, NewsCollectionViewCellData.ID>
        
    func initDataSource(collectionView: UICollectionView) {
        let loaderCellRegistration = UICollectionView.CellRegistration<LoaderCollectionViewCell, NewsCollectionViewCellData.ID> { (cell, indexPath, itemId) in
            cell.startActivity()
        }

        let newsCellRegistration = UICollectionView.CellRegistration<NewsCollectionViewCell, NewsCollectionViewCellData.ID> { [weak self] (cell, indexPath, itemId) in
            cell.data = self?.items[itemId]
        }
                
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemId in
            switch Section(rawValue: indexPath.section)! {
            case .news:
                collectionView.dequeueConfiguredReusableCell(using: newsCellRegistration, for: indexPath, item: itemId)
            case .loader:
                collectionView.dequeueConfiguredReusableCell(using: loaderCellRegistration, for: indexPath, item: itemId)
            }
        })
        
        var snapshot = Snapshot()
        snapshot.appendSections([.news, .loader])
        snapshot.appendItems([0], toSection: .loader)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    func setNews(_ news: [News], isMaximum: Bool) {
        guard let dataSource else {
            return
        }
        
        let newIds = Set(news.map(\.id)).subtracting(Set(items.keys))
        
        news.forEach {
            let defaultImage = $0.hasImage ? nil : UIImage(named: "autodocLogo")!
            let item = NewsCollectionViewCellData(id: $0.id,
                                                  title: $0.title,
                                                  description: $0.description,
                                                  imageHolder: $0.imageHolder,
                                                  defaultImage: defaultImage)
            items[$0.id] = item
        }
        
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(Array(newIds).sorted(by: >), toSection: .news)
        if isMaximum {
            snapshot.deleteSections([.loader])
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    var itemsCount: Int {
        dataSource?.snapshot().itemIdentifiers.count ?? 0
    }
    
    func idForCell(at row: Int) -> Int? {
        guard let snapshot = dataSource?.snapshot() else {
            return nil
        }
        
        return snapshot.itemIdentifiers[row]
    }
    
    nonisolated enum Section: Int, CaseIterable {
        case news
        case loader
    }
}
