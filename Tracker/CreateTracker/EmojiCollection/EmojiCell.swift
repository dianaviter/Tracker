//
//  EmojiCell.swift
//  Tracker
//
//  Created by Diana Viter on 15.04.2025.
//

import UIKit

final class EmojiCell: UICollectionViewCell {
    static let cellIdentifier = "emojiCell"
    
    private let emoji: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with symbol: String) {
        emoji.text = symbol
    }
    
    private func setUpConstraints() {
        emoji.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emoji)
        
        NSLayoutConstraint.activate([
            emoji.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emoji.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
