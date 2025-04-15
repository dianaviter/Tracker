//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Diana Viter on 28.03.2025.
//

import UIKit

// MARK: - ViewController

final class TrackerViewController: UIViewController {
    
    // MARK: - Properties
    
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var filteredCategories: [TrackerCategory] = []
    private var numberOfDays = 0
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    private var defaultCategory = TrackerCategory(header: "Все трекеры", trackers: [])
    private var currentDate = Date()
    
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
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.cellIdentifier)
        collectionView.register(TrackerSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        datePicker.date = currentDate
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
            let filteredTrackers = category.trackers.filter { tracker in
                if let schedule = tracker.schedule, !schedule.isEmpty {
                    return schedule.contains { $0.rawValue == selectedDay }
                } else {
                    let wasMarked = completedTrackers.contains {
                        $0.id == tracker.id
                    }
                    if wasMarked {
                        return completedTrackers.contains {
                            $0.id == tracker.id &&
                            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
                        }
                    } else {
                        return true
                    }
                }
            }
            return TrackerCategory(header: category.header, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
        
        showContentOrPlaceholder()
    }
    
    @objc func addButtonCLicked(_ sender: CreateTrackerViewController) {
        let vc = CreateTrackerViewController()
        vc.onTrackerCreated = { [weak self] tracker in
            self?.addNewTracker(tracker)
            self?.collectionView.reloadData()
        }
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
    
    func addNewTracker(_ tracker: Tracker) {
        if let index = categories.firstIndex(where: { $0.header == "Все категории" }) {
            let oldCategory = categories[index]
            let updatedTrackers = oldCategory.trackers + [tracker]
            let newCategory = TrackerCategory(header: oldCategory.header, trackers: updatedTrackers)
            categories[index] = newCategory
        } else {
            let newCategory = TrackerCategory(header: "Все категории", trackers: [tracker])
            categories.append(newCategory)
        }
        datePickerValueChanged(datePicker)
    }
    
    private func updateNumberOfDays(_ tracker: Tracker) {
        
        guard datePicker.date <= currentDate else { return }
        
        let existingIndex = completedTrackers.firstIndex {
            $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: self.datePicker.date)
        }
        if let index = existingIndex {
            completedTrackers.remove(at: index)
        } else {
            completedTrackers.append(TrackerRecord(id: tracker.id, date: datePicker.date))
        }
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
            
            collectionView.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 24),
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.cellIdentifier, for: indexPath) as? TrackerCell
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        let isCompleted = completedTrackers.contains { $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: datePicker.date) }
        let daysCount = completedTrackers.filter { $0.id == tracker.id }.count
        
        cell?.configure(tracker: tracker, isCompleted: isCompleted, daysCount: daysCount)
        
        cell?.onPlusTapped = { [weak self] in
            self?.updateNumberOfDays(tracker)
            self?.collectionView.reloadItems(at: [indexPath])
        }
        return cell ?? UICollectionViewCell()
    }
    
    internal func collectionView(_: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
                fatalError("Unsupported kind: \(kind)")
            }
            
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "header",
                for: indexPath
            ) as? TrackerSectionHeader else {
                fatalError("Could not dequeue TrackerSectionHeader")
            }

            header.headerLabel.text = filteredCategories[indexPath.section].header
            return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 44)
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
