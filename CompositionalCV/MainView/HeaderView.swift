//
//  HeaderView.swift
//  5-JayCompositional
//
//  Created by Jay Muthialu on 1/11/20.
//  Copyright © 2020 Jay Muthialu. All rights reserved.
//

import UIKit

class HeaderView: UICollectionReusableView {
    
    static let reuseIdentifier = "headerReuseID"
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configureView() {
        backgroundColor = .clear
        label.textColor = .systemTeal
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        let inset = CGFloat(10)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: inset),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -inset),
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: inset),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -inset)
        ])
        label.font = UIFont.preferredFont(forTextStyle: .title3)
    }
        
}
