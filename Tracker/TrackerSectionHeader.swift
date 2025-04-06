//
//  SectionHEader.swift
//  Tracker
//
//  Created by Diana Viter on 04.04.2025.
//

import UIKit

final class TrackerSectionHeader: UICollectionReusableView {
    let headerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "YSDisplay-Bold", size: 19)
        label.textColor = .trackerBlack
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
