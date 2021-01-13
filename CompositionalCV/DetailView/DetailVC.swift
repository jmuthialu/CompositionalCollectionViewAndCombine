//
//  DetailVC.swift
//  5-JayCompositional
//
//  Created by Jay Muthialu on 1/3/20.
//  Copyright © 2020 Jay Muthialu. All rights reserved.
//

import UIKit
import Combine

class DetailVC: UIViewController {
    
    var collectionView: UICollectionView! = nil
    var dataSource: UICollectionViewDiffableDataSource<Section, PictureModel>! = nil
    var cancellables = Set<AnyCancellable>()
    var originalPictures = [PictureModel]()
    var pictures = [PictureModel]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.snapShotForCurrentState(dataSource: self.dataSource)
            }
        }
    }
    
    enum Section {
        case photos
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.refresh, target: self, action: #selector(refreshTapped))
        navigationItem.rightBarButtonItem = refreshButton
           
        createCollectionView()
        configureDataSource()
        
        guard let url = NetworkLayer.constructURL(searchTerm: Constants.detailViewSearchTerm) else { return }
        
        
        NetworkLayer.loadData(url: url) {
            [weak self] (feed: FeedModel?, error: Error?) in
            
            guard let pictures = feed?.pictures, error == nil else {
                print("Error occured loading Data: \(String(describing: error))")
                return
            }
            self?.pictures = pictures
            self?.originalPictures = pictures
        }
    }
    
    func createCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: generateLayout())
        self.view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "photoCell")
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource
            <Section, PictureModel>(collectionView: self.collectionView) { [weak self]
                (collectionView, indexPath, pictureModel) -> UICollectionViewCell? in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell
                cell.configure(pictureModel: pictureModel, imageCache: imageCache)
                return cell
        }
        snapShotForCurrentState(dataSource: dataSource)
    }
    
    // This is the new reloadData(). You can call this method after data has changed
    // and it will redraw the collection view as needed.
    func snapShotForCurrentState(
        dataSource: UICollectionViewDiffableDataSource<Section, PictureModel>) {
        
        if pictures.count > 0 {
            print("Snapshot count: \(pictures.count)")
            var snapShot = NSDiffableDataSourceSnapshot<Section, PictureModel>()
            snapShot.appendSections([Section.photos])
            snapShot.appendItems(pictures)
            dataSource.apply(snapShot, animatingDifferences: true)
        } else {
            print("Empty Snapshot")
        }
        
    }
    
    func generateLayout() -> UICollectionViewLayout {
        
          // 1st Group - Full Photo
          let fullPhotoItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(2/3))
          let fullPhotoItem = NSCollectionLayoutItem(layoutSize: fullPhotoItemSize)
          fullPhotoItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
          
          // 2nd Group - One Main and one pair
          let mainItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(2/3), heightDimension: .fractionalHeight(1.0))
          let mainItem = NSCollectionLayoutItem(layoutSize: mainItemSize)
          mainItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
          
          let pairItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1/2))
          let pairItem = NSCollectionLayoutItem(layoutSize: pairItemSize)
          pairItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
          
          let trailingGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1.0))
          let trailingGroup = NSCollectionLayoutGroup.vertical(layoutSize: trailingGroupSize, subitem: pairItem, count: 2)
          
          let mainWithPairGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(4/9))
          let mainWithPairGroup = NSCollectionLayoutGroup.horizontal(layoutSize: mainWithPairGroupSize, subitems: [mainItem, trailingGroup])
          
          
          // 3rd group - Triplet
          let tripletItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1.0))
          let tripletItem = NSCollectionLayoutItem(layoutSize: tripletItemSize)
          tripletItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
          
          let tripletItemGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(2/9))
          let tripletItemGroup = NSCollectionLayoutGroup.horizontal(layoutSize: tripletItemGroupSize, subitem: tripletItem, count: 3)
          
          // 4th group - Reverse of 2nd group
          let mainPairWithReversedGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(4/9))
          let mainPairWithReversedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: mainPairWithReversedGroupSize, subitems: [trailingGroup, mainItem])
        
          // Combine all groups
          let nestedGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(16/9))
          let nestedGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: nestedGroupSize,
            subitems: [
              fullPhotoItem,
              mainWithPairGroup,
              tripletItemGroup,
              mainPairWithReversedGroup
          ])
          
          let section = NSCollectionLayoutSection(group: nestedGroup)
            
          let layout = UICollectionViewCompositionalLayout(section: section)
          return layout
    }
    
    @objc func refreshTapped() {
        if pictures.count > 3 {
            pictures = Array(originalPictures.shuffled().prefix(3))
        } else {
            pictures = originalPictures.shuffled()
        }
    }

}

extension DetailVC: UICollectionViewDelegate {}
 
