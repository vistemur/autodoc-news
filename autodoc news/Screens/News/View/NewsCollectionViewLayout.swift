import UIKit

class NewsCollectionViewLayout: UICollectionViewCompositionalLayout {
    
    convenience init() {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        self.init(sectionProvider: { section, enviroment in
            switch NewsModel.Section(rawValue: section)! {
            case .news:
                Self.getNewsSectionLayout(enviroment: enviroment)
            case .loader:
                Self.getLoaderSectionLayout(enviroment: enviroment)
            }
        }, configuration: configuration)
    }
    
    private static func getNewsSectionLayout(enviroment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemsInRow = CGFloat(Int(enviroment.container.contentSize.width / 300))
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / itemsInRow),
            heightDimension: .fractionalWidth(1.0 / itemsInRow * 0.65))
        let newsItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1.0 / itemsInRow * 0.65))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [newsItem])
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    private static func getLoaderSectionLayout(enviroment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(100.0))
        let loaderItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(100.0))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [loaderItem])
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
}
