//
//  EmojiSectionHeader.swift
//  Tracker
//
//  Created by Diana Viter on 15.04.2025.
//

import UIKit

final class EmojiSectionHeader: UICollectionReusableView {
    let headerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = .trackerBlack
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 7),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerLabel.heightAnchor.constraint(equalToConstant: 18),
            headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
