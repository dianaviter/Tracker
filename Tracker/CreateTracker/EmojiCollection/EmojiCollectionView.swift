//
//  CreateTrackerEmojiCollection.swift
//  Tracker
//
//  Created by Diana Viter on 15.04.2025.
//

import UIKit

final class EmojiCollectionView: UIView {
    
    let emojiCollection = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    
    var selectedEmoji: String? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionview.backgroundColor = .clear
        return collectionview
    }()
    var onEmojiSelected: ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.cellIdentifier)
        collectionView.register(EmojiSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EmojiCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojiCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.cellIdentifier, for: indexPath) as? EmojiCell
        let emoji = emojiCollection[indexPath.row]
        cell?.configure(with: emoji)
        
        if emoji == selectedEmoji {
            cell?.backgroundColor = .trackerLightGray
            cell?.clipsToBounds = true
            cell?.layer.cornerRadius = 16
        } else {
            cell?.backgroundColor = .clear
        }
        
        return cell ?? UICollectionViewCell()
    }
}

extension EmojiCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            fatalError("Unsupported kind: \(kind)")
        }

        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? EmojiSectionHeader else {
            fatalError("Could not dequeue EmojiSectionHeader")
        }
        header.headerLabel.text = NSLocalizedString("emoji.headerLabel", comment: "")
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selected = emojiCollection[indexPath.row]
        selectedEmoji = selected
        onEmojiSelected?(selected)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell
        cell?.backgroundColor = .clear
    }
}

extension EmojiCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 48)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let interСellSpace = 5
        let leftSpace = 18
        let rightSpace = 19
        let totalSpace = interСellSpace * 6 + leftSpace + rightSpace
        let width = (Int(collectionView.frame.width) - totalSpace)/6
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_: UICollectionView, layout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
    }
}
