//
//  PhotoCell.swift
//  JayCollectionView
//
//  Created by Jay Muthialu on 1/4/20.
//  Copyright © 2020 Jay Muthialu. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        self.imageView.contentMode = .scaleAspectFill
    }
    
    func configure(pictureModel: PictureModel, imageCache: NSCache<NSString, UIImage>) {
        
        guard let urlString = pictureModel.fullUrl,
            let url = URL(string: urlString) else { return }
        
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            DispatchQueue.main.async {
                   self.imageView.image = cachedImage
               }
        } else {
            print("No cache: \(urlString)")
            DispatchQueue.global().async {
                guard let data = try? Data(contentsOf: url),
                    let image = UIImage(data: data) else { return }
                imageCache.setObject(image, forKey: urlString as NSString)
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }
    }
    
}
