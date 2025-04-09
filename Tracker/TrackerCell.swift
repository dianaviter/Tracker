//
//  TrackerCell.swift
//  Tracker
//
//  Created by Diana Viter on 03.04.2025.
//

import UIKit

final class TrackerCell: UICollectionViewCell {
    let cellIdentifier = "cell"
    let trackerController = TrackerViewController()
    var updateNumberOfDays: (() -> Void)?
    
    private let cellEmoji: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    private let cellTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .trackerWhite
        label.numberOfLines = 2
        return label
    }()
    
    private let cellDays: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 1
        label.textColor = .trackerBlack
        return label
    }()
    
    private let cellButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 17
        button.clipsToBounds = true
        button.tintColor = .white
        return button
    }()
    
    private let cellBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let emojiBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpConstraints()
        cellButton.addTarget(self, action: #selector(cellButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func cellButtonTapped() {
        updateNumberOfDays?()
    }
    
    func configure(tracker: Tracker, isCompleted: Bool, daysCount: Int) {
        cellTextLabel.text = tracker.name
        cellEmoji.text = tracker.emoji ?? "🙂"
        cellDays.text = "\(daysCount) дней"
        cellBackground.backgroundColor = tracker.color

        if isCompleted {
            cellButton.backgroundColor = tracker.color?.withAlphaComponent(0.8)
            cellButton.setImage(UIImage(named: "cellButtonDone"), for: .normal)
        } else {
            cellButton.backgroundColor = tracker.color
            cellButton.setImage(UIImage(systemName: "plus"), for: .normal)
        }
    }
    
    private func setUpConstraints() {
        [cellEmoji, cellDays, cellButton, cellBackground, cellTextLabel, emojiBackground].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        contentView.addSubview(cellBackground)
        cellBackground.addSubview(emojiBackground)
        cellBackground.addSubview(cellEmoji)
        cellBackground.addSubview(cellTextLabel)
        contentView.addSubview(cellDays)
        contentView.addSubview(cellButton)
        
        NSLayoutConstraint.activate([
            cellBackground.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellBackground.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellBackground.heightAnchor.constraint(equalToConstant: 90),
            
            emojiBackground.widthAnchor.constraint(equalToConstant: 24),
            emojiBackground.heightAnchor.constraint(equalToConstant: 24),
            emojiBackground.leadingAnchor.constraint(equalTo: cellTextLabel.leadingAnchor),
            emojiBackground.topAnchor.constraint(equalTo: cellBackground.topAnchor, constant: 12),
            
            cellEmoji.centerYAnchor.constraint(equalTo: emojiBackground.centerYAnchor),
            cellEmoji.centerXAnchor.constraint(equalTo: emojiBackground.centerXAnchor),
            
            cellTextLabel.topAnchor.constraint(equalTo: emojiBackground.bottomAnchor, constant: 8),
            cellTextLabel.leadingAnchor.constraint(equalTo: cellBackground.leadingAnchor, constant: 12),
            cellTextLabel.trailingAnchor.constraint(equalTo: cellBackground.trailingAnchor, constant: -12),
            
            cellDays.topAnchor.constraint(equalTo: cellBackground.bottomAnchor, constant: 8),
            cellDays.leadingAnchor.constraint(equalTo: cellBackground.leadingAnchor, constant: 12),
            cellDays.centerYAnchor.constraint(equalTo: cellButton.centerYAnchor),
            
            cellButton.topAnchor.constraint(equalTo: cellBackground.bottomAnchor, constant: 8),
            cellButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            cellButton.widthAnchor.constraint(equalToConstant: 34),
            cellButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
}
