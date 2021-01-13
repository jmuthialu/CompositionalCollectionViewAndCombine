//
//  MainVC.swift
//  5-JayCompositional
//
//  Created by Jay Muthialu on 1/11/20.
//  Copyright © 2020 Jay Muthialu. All rights reserved.
//

import UIKit
import Combine

var imageCache = NSCache<NSString, UIImage>()

enum Section: String, CaseIterable {
    case featured = "Featured Album"
    case shared = "Shared Album"
    case general = "General Album"
}

class MainVC: UIViewController {
    
    var collectionView: UICollectionView?
    var dataSource: UICollectionViewDiffableDataSource<Section, PictureModel>! = nil
    static let sectionHeaderElementKind = "section-header-element-kind"
    
    var viewModel = MainViewModel()
    var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
           
        createCollectionView()
        configureDataSource()
        
        bindToPublisher()
        viewModel.loadData()
    }
    
    func bindToPublisher() {
        guard let featuredPub = viewModel.featuredPub,
              let sharedPub = viewModel.sharedPub,
              let generalPub = viewModel.generalPub else { return }
        
        // calls updateDataSource when all 3 notifications are posted
        let _ = Publishers.Zip3(featuredPub, sharedPub, generalPub)
          .sink { [weak self] val in
              self?.updateDataSource()
          }.store(in: &cancellables)
    }
    
    func createCollectionView() {
        self.collectionView = UICollectionView(frame: view.bounds,
                                               collectionViewLayout: generateLayoutForAllSections())
        guard let collectionView = self.collectionView else { return }
        
        self.view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        collectionView.delegate = self
        
        collectionView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "photoCell")
        collectionView.register(HeaderView.self,
                                forSupplementaryViewOfKind: MainVC.sectionHeaderElementKind,
                                withReuseIdentifier: HeaderView.reuseIdentifier)
    }
    
    func configureDataSource() {
        guard let collectionView = collectionView else { return }
        
        dataSource = UICollectionViewDiffableDataSource
            <Section, PictureModel>(collectionView: collectionView) {
                (collectionView, indexPath, pictureModel) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else { return nil }
            cell.configure(pictureModel: pictureModel, imageCache: imageCache)
            return cell
            
        }
        
        dataSource.supplementaryViewProvider = { (
          collectionView: UICollectionView,
          kind: String,
          indexPath: IndexPath) -> UICollectionReusableView? in

          guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: HeaderView.reuseIdentifier,
            for: indexPath) as? HeaderView else { fatalError("Cannot create header view") }

          supplementaryView.label.text = Section.allCases[indexPath.section].rawValue
          return supplementaryView
        }
        
    }
    
    func updateDataSource() {
        print("updateDataSource ...")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if self.viewModel.featuredPictures.count > 0 &&
                self.viewModel.sharedPictures.count > 0 &&
                self.viewModel.generalPictures.count > 0 {
                var snapShot = NSDiffableDataSourceSnapshot<Section, PictureModel>()
                snapShot.appendSections([Section.featured])
                snapShot.appendItems(self.viewModel.featuredPictures)
                snapShot.appendSections([Section.shared])
                snapShot.appendItems(self.viewModel.sharedPictures)
                snapShot.appendSections([Section.general])
                snapShot.appendItems(self.viewModel.generalPictures)
                self.dataSource.apply(snapShot, animatingDifferences: true)
            } else {
                print("Snapshot empty")
            }
            
        }
    }
    
    func generateLayoutForAllSections() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let `self` = self else { return nil }
            let section = Section.allCases[sectionIndex]
            switch section {
            case .featured: return self.featuredLayout()
            case .shared: return self.sharedLayout()
            case .general: return self.generalLayout()
            }
        }
        return layout
    }
    
    func featuredLayout() -> NSCollectionLayoutSection {
        let featuredSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let featuredItem = NSCollectionLayoutItem(layoutSize: featuredSize)
        let featuredGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.90), heightDimension: .fractionalWidth(9/16))
        let featuredGroup = NSCollectionLayoutGroup.horizontal(layoutSize: featuredGroupSize, subitem: featuredItem, count: 1)
        featuredGroup.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 0)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .estimated(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
          layoutSize: headerSize,
          elementKind: MainVC.sectionHeaderElementKind,
          alignment: .top)

        let section = NSCollectionLayoutSection(group: featuredGroup)
        section.boundarySupplementaryItems = [sectionHeader]
        section.orthogonalScrollingBehavior = .groupPaging
        return section
    }
    
    func sharedLayout() -> NSCollectionLayoutSection {

        let lhSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let lhItem = NSCollectionLayoutItem(layoutSize: lhSize)
        let lhGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(240))
        let lhGroup = NSCollectionLayoutGroup.vertical(layoutSize: lhGroupSize, subitem: lhItem, count: 2)

        let rhSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let rhItem = NSCollectionLayoutItem(layoutSize: rhSize)
        let rhGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(240))
        let rhGroup = NSCollectionLayoutGroup.vertical(layoutSize: rhGroupSize, subitem: rhItem, count: 2)

        let sharedGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(240))
        let sharedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: sharedGroupSize, subitems: [lhGroup,rhGroup])
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .estimated(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
          layoutSize: headerSize,
          elementKind: MainVC.sectionHeaderElementKind,
          alignment: .top)

        let section = NSCollectionLayoutSection(group: sharedGroup)
        section.boundarySupplementaryItems = [sectionHeader]
        section.orthogonalScrollingBehavior = .continuous
        return section
    }
    
    func generalLayout() -> NSCollectionLayoutSection {
        let generalSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let generalItem = NSCollectionLayoutItem(layoutSize: generalSize)
        let generalGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(2/3))
        let generalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: generalGroupSize, subitem: generalItem, count: 2)
        generalGroup.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 0)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .estimated(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
          layoutSize: headerSize,
          elementKind: MainVC.sectionHeaderElementKind,
          alignment: .top)

        let section = NSCollectionLayoutSection(group: generalGroup)
        section.boundarySupplementaryItems = [sectionHeader]
        section.orthogonalScrollingBehavior = .groupPaging
        return section
    }
    
}

    
extension MainVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = DetailVC()
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
}
