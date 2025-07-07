//
//  TrackerColorCollectionView.swift
//  Tracker
//
//  Created by Diana Viter on 15.04.2025.
//

import UIKit

final class TrackerColorCollectionView: UIView {
    
    let trackerColors: [UIColor] = [
        .trackerColor1, .trackerColor2, .trackerColor3, .trackerColor4, .trackerColor5, .trackerColor6,
        .trackerColor7, .trackerColor8, .trackerColor9, .trackerColor10, .trackerColor11, .trackerColor12,
        .trackerColor13, .trackerColor14, .trackerColor15, .trackerColor16, .trackerColor17, .trackerColor18
    ]
    
    var selectedColor: UIColor? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var selectedColorHex: String? {
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
    
    var onSelectedColor: ((UIColor) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(TrackerColorCell.self, forCellWithReuseIdentifier: TrackerColorCell.cellIdentifier)
        collectionView.register(TrackerColorHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
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

extension TrackerColorCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trackerColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerColorCell.cellIdentifier, for: indexPath) as? TrackerColorCell
        let color = trackerColors[indexPath.row]
        let colorHex = UIColorMarshalling().hexString(from: color)
        let isSelected = (colorHex == selectedColorHex)

        cell?.configure(with: color, isSelected: isSelected)
        
        return cell ?? UICollectionViewCell()
    }
}

extension TrackerColorCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            fatalError("Unsupported kind: \(kind)")
        }

        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? TrackerColorHeader else {
            fatalError("Could not dequeue TrackerColorHeader")
        }
        header.headerLabel.text = NSLocalizedString("color.headerLabel", comment: "")
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selected = trackerColors[indexPath.row]
        selectedColor = selected
        selectedColorHex = UIColorMarshalling().hexString(from: selected)
        onSelectedColor?(selected)
    }
}

extension TrackerColorCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 48)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let interCellSpace = 5
        let leftSpace = 18
        let rightSpace = 19
        let totalSpace = interCellSpace * 6 + leftSpace + rightSpace
        let width = (Int(collectionView.frame.width) - totalSpace)/6
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_: UICollectionView, layout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
    }
}
