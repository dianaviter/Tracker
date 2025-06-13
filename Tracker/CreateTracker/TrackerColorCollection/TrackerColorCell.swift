//
//  TrackerColorCell.swift
//  Tracker
//
//  Created by Diana Viter on 15.04.2025.
//

import UIKit

final class TrackerColorCell: UICollectionViewCell {
    static let cellIdentifier = "colorCell"
    
    private let trackerColor: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        return view
    }()

    private let cellBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with color: UIColor, isSelected: Bool) {
        trackerColor.backgroundColor = color
        
        if isSelected {
            cellBackground.layer.borderWidth = 3
            cellBackground.layer.borderColor = color.withAlphaComponent(0.3).cgColor
            cellBackground.backgroundColor = .clear
        } else {
            cellBackground.layer.borderWidth = 0
            cellBackground.layer.borderColor = nil
            cellBackground.backgroundColor = .clear
        }
    }
    
    private func setUpConstraints() {
        [trackerColor, cellBackground].forEach {
            $0?.translatesAutoresizingMaskIntoConstraints = false
        }
        
        contentView.addSubview(cellBackground)
        contentView.addSubview(trackerColor)
        
        NSLayoutConstraint.activate([
            cellBackground.heightAnchor.constraint(equalToConstant: 52),
            cellBackground.widthAnchor.constraint(equalToConstant: 52),
            cellBackground.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            cellBackground.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            trackerColor.heightAnchor.constraint(equalToConstant: 40),
            trackerColor.widthAnchor.constraint(equalToConstant: 40),
            trackerColor.centerXAnchor.constraint(equalTo: cellBackground.centerXAnchor),
            trackerColor.centerYAnchor.constraint(equalTo: cellBackground.centerYAnchor)
        ])
    }
}
