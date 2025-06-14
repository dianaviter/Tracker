//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Diana Viter on 28.03.2025.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    var totalCompletedTrackers: Int?
    private let completedTrackersView = StatisticsCardView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statistics.title", comment: "")
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .trackerBlack
        return label
    }()
    
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "noStatistics")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statistics.placeholder", comment: "")
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .trackerBlack
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .trackerWhite
        setupLayout()
        loadStatistics()
    }

    private func setupLayout() {
        [titleLabel, placeholderImageView, placeholderLabel, completedTrackersView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -24),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),

            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            
            completedTrackersView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            completedTrackersView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            completedTrackersView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            completedTrackersView.heightAnchor.constraint(equalToConstant: 90),
        ])
    }
    
    func localizedTrackersCount(_ count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100

        if remainder100 >= 11 && remainder100 <= 14 {
            return "Трекеров"
        } else if remainder10 == 1 {
            return "Трекер"
        } else if remainder10 >= 2 && remainder10 <= 4 {
            return "Трекера"
        } else {
            return "Трекеров"
        }
    }
    
    private func loadStatistics() {
        do {
            let records = try TrackerRecordStore.shared?.trackerRecords() ?? []
            totalCompletedTrackers = records.count

            if totalCompletedTrackers ?? 0 > 0 {
                let value = totalCompletedTrackers ?? 0
                let word = localizedTrackersCount(value)
                completedTrackersView.configure(value: "\(value)", title: "\(word) завершено")
                completedTrackersView.isHidden = false
                placeholderImageView.isHidden = true
                placeholderLabel.isHidden = true
            } else {
                completedTrackersView.isHidden = true
                placeholderImageView.isHidden = false
                placeholderLabel.isHidden = false
            }
        } catch {
            print("Ошибка загрузки статистики: \(error)")
        }
    }
}

