//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Diana Viter on 28.03.2025.
//

import UIKit

// MARK: - Models

struct Tracker {
    let id: UUID
    let name: String?
    let color: UIColor?
    let emoji: String?
    let schedule: Schedule?
}

struct Schedule {
    let dayOfWeek: String?
}

struct TrackerCategory {
    let header: String?
    let trackers: [Tracker]
}

struct TrackerRecord {
    let id: UUID?
    let date: Date?
}

// MARK: - ViewController

final class TrackerViewController: UIViewController {
    
    // MARK: - Properties
    
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    var filteredCategories: [TrackerCategory] = []
    let cellIdentifier = "cell"
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    // MARK: - UI Elements
    
    private let firstTrackerImageView: UIImageView = {
        let image = UIImage(named: "createFirstTrackerImage")
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 147, y: 402, width: 80, height: 80)
        return imageView
    }()
    
    private let imageTextLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.text = "Что будем отслеживать?"
        textLabel.font = .systemFont(ofSize: 12, weight: .medium)
        textLabel.textColor = .trackerBlack
        return textLabel
    }()
    
    private let trackerLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.text = "Трекеры"
        textLabel.font = .systemFont(ofSize: 34, weight: .bold)
        textLabel.textColor = .trackerBlack
        return textLabel
    }()
    
    private let addTracker: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "addTracker"), for: .normal)
        return button
    }()
    
    private let searchButton: UISearchTextField = {
        let searchbar = UISearchTextField()
        searchbar.placeholder = "Поиск"
        searchbar.backgroundColor = .white
        return searchbar
    }()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "ru_RU")
        picker.preferredDatePickerStyle = .compact
        return picker
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .trackerWhite
        setUpConstraints()
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        addTracker.addTarget(self, action: #selector(addButtonCLicked(_:)), for: .touchUpInside)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(TrackerSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        let today = Date()
        datePicker.date = today
        updateTrackers(for: today)
        showContentOrPlaceholder()
    }
    
    // MARK: - Actions
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEEE"
        let selectedDay = formatter.string(from: selectedDate).capitalized
        
        filteredCategories = categories.map { category in
            let filteredTrackers = category.trackers.filter {
                $0.schedule?.dayOfWeek == selectedDay
            }
            return TrackerCategory(header: category.header, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
        
        showContentOrPlaceholder()
    }
    
    @objc func addButtonCLicked(_ sender: UIButton) {
        let vc = CreateTrackerViewController()
        present(vc, animated: true)
    }
    
    // MARK: - Actions
    
    private func showContentOrPlaceholder() {
        let hasTrackers = filteredCategories.contains { !$0.trackers.isEmpty
        }
        collectionView.isHidden = !hasTrackers
        firstTrackerImageView.isHidden = hasTrackers
        imageTextLabel.isHidden = hasTrackers
        
        collectionView.reloadData()
    }
    
    private func updateTrackers(for date: Date) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEEE"
        let selectedDay = formatter.string(from: date).capitalized
        
        let newTracker = Tracker(id: UUID(), name: "New Tracker", color: .trackerRed, emoji: "😻", schedule: Schedule(dayOfWeek: selectedDay))
        let newTracker12 = Tracker(id: UUID(), name: "New Tracker", color: .trackerRed, emoji: "😻", schedule: Schedule(dayOfWeek: selectedDay))
        let newTracker13 = Tracker(id: UUID(), name: "New Tracker", color: .trackerRed, emoji: "😻", schedule: Schedule(dayOfWeek: selectedDay))
        let newCategory = TrackerCategory(header: "New Category", trackers: [newTracker, newTracker12, newTracker13])
        let newTracker2 = Tracker(id: UUID(), name: "New Tracker2", color: .trackerRed, emoji: "😻", schedule: Schedule(dayOfWeek: selectedDay))
        let newCategory2 = TrackerCategory(header: "New Category2", trackers: [newTracker2])
        
        filteredCategories = [newCategory, newCategory2]
        collectionView.reloadData()
    }
    
    // MARK: - Layout
    
    private func setUpConstraints() {
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 84
        
        [firstTrackerImageView, imageTextLabel, addTracker, trackerLabel, searchButton, datePicker, collectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            firstTrackerImageView.widthAnchor.constraint(equalToConstant: 80),
            firstTrackerImageView.heightAnchor.constraint(equalToConstant: 80),
            firstTrackerImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            firstTrackerImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            imageTextLabel.centerXAnchor.constraint(equalTo: firstTrackerImageView.centerXAnchor),
            imageTextLabel.topAnchor.constraint(equalTo: firstTrackerImageView.bottomAnchor, constant: 8),
            
            addTracker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            addTracker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            
            trackerLabel.topAnchor.constraint(equalTo: addTracker.bottomAnchor, constant: 1),
            trackerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            searchButton.topAnchor.constraint(equalTo: trackerLabel.bottomAnchor, constant: 8),
            searchButton.leadingAnchor.constraint(equalTo: trackerLabel.leadingAnchor),
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchButton.widthAnchor.constraint(equalToConstant: 343),
            searchButton.heightAnchor.constraint(equalToConstant: 36),
            
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            datePicker.centerYAnchor.constraint(equalTo: addTracker.centerYAnchor),
            datePicker.heightAnchor.constraint(equalToConstant: 34),
            
            collectionView.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -tabBarHeight)
        ])
    }
}

// MARK: - UICollectionViewDataSource

extension TrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? TrackerCell
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        let isCompleted = completedTrackers.contains { $0.id == tracker.id }
        let daysCount = completedTrackers.filter { $0.id == tracker.id }.count
        
        cell?.configure(tracker: tracker, isCompleted: isCompleted, daysCount: daysCount)
        
        cell?.updateNumberOfDays = { [weak self] in
            guard let self else { return }
            let today = Date()
            
            guard datePicker.date <= today else {
                return
            }
            
            let existingIndex = completedTrackers.firstIndex {
                $0.id == tracker.id
            }
            if let index = existingIndex {
                completedTrackers.remove(at: index)
            } else {
                completedTrackers.append(TrackerRecord(id: tracker.id, date: datePicker.date))
            }
            
            self.collectionView.reloadItems(at: [indexPath])
        }
        
        return cell ?? UICollectionViewCell()
    }
    
    internal func collectionView(_: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        case UICollectionView.elementKindSectionFooter:
            id = "footer"
        default:
            id = ""
        }
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as? TrackerSectionHeader
        view?.headerLabel.text = filteredCategories[indexPath.section].header
        return view ?? UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        return headerView.systemLayoutSizeFitting(
            CGSize(width: collectionView.frame.width, height: 18)
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let leftInset = 16
        let rightInset = 16
        let interItemSpacing = 9
        return CGSize(width: (Int(collectionView.bounds.width) - leftInset - rightInset - interItemSpacing)/2, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
}
