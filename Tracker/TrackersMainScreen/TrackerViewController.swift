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
    private var visibleCategories: [TrackerCategory] = []
    private var numberOfDays = 0
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    private var currentDate = Date()
    private var trackerStore: TrackerStore?
    private var coreDataStack = CoreDataStack()
    private var trackerRecordStore: TrackerRecordStore?
    private var trackerCategoryStore: TrackerCategoryStore?
    
    // MARK: - UI Elements
    
    private let firstTrackerImageView: UIImageView = {
        let image = UIImage(named: "createFirstTrackerImage")
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 147, y: 402, width: 80, height: 80)
        return imageView
    }()
    
    private let imageTextLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.text = NSLocalizedString("trackerview.placeholder.text", comment: "")
        textLabel.font = .systemFont(ofSize: 12, weight: .medium)
        textLabel.textColor = .trackerBlack
        return textLabel
    }()
    
    private let trackerLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.text = NSLocalizedString("trackerview.title", comment: "")
        textLabel.font = .systemFont(ofSize: 34, weight: .bold)
        textLabel.textColor = .trackerBlack
        return textLabel
    }()
    
    private let addTracker: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        let plusImage = UIImage(systemName: "plus", withConfiguration: config)
        button.setImage(plusImage, for: .normal)
        button.tintColor = .trackerBlack
        return button
    }()

    private let searchButton: UISearchTextField = {
        let searchbar = UISearchTextField()
        let placeholderText = NSLocalizedString("trackerview.search.placeholder", comment: "")
        searchbar.attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: [
                .foregroundColor: UIColor.trackerGray
            ]
        )
        if let leftImageView = searchbar.leftView as? UIImageView {
            leftImageView.tintColor = .trackerGray
        }
        searchbar.backgroundColor = .trackerWhite
        return searchbar
    }()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.backgroundColor = .trackerLightGray
        picker.layer.cornerRadius = 8
        picker.clipsToBounds = true
        picker.setValue(UIColor.black, forKey: "textColor")
        return picker
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .trackerWhite
        setUpConstraints()
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        addTracker.addTarget(self, action: #selector(addButtonCLicked(_:)), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(searchTextChanged(_:)), for: .editingChanged)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.cellIdentifier)
        collectionView.register(TrackerSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.backgroundColor = .trackerWhite
        
        datePicker.date = currentDate
        
        initializeStores()
        updateDatePickerStyle()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateDatePickerStyle()
    }
    
    // MARK: - Actions
    
    @objc private func searchTextChanged(_ sender: UISearchTextField) {
        let query = sender.text?.lowercased() ?? ""
        
        if query.isEmpty {
            visibleCategories = filteredCategories
        } else {
            visibleCategories = filteredCategories.map { category in
                let filteredTrackers = category.trackers.filter {
                    let name = $0.name ?? ""
                    return name.lowercased().contains(query)
                }
                return TrackerCategory(header: category.header, trackers: filteredTrackers)
            }.filter { !$0.trackers.isEmpty }
        }
        
        showContentOrPlaceholder()
    }
    
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        updateVisibleCategories(for: sender.date)
    }
    
    @objc func addButtonCLicked(_ sender: CreateTrackerViewController) {
        let vc = CreateTrackerViewController()
        vc.onTrackerCreated = { [weak self] tracker, category in
            self?.addNewTracker(tracker, to: category)
            self?.collectionView.reloadData()
        }
        present(vc, animated: true)
    }
    
    // MARK: - Actions
    
    private func updateDatePickerStyle() {
        if traitCollection.userInterfaceStyle == .dark {
            datePicker.overrideUserInterfaceStyle = .light
            datePicker.backgroundColor = .white
            datePicker.setValue(UIColor.black, forKey: "textColor")
        } else {
            datePicker.overrideUserInterfaceStyle = .light
        }
    }
    
    private func initializeStores() {
        let context = coreDataStack.persistentContainer.viewContext
        
        do {
            trackerStore = try TrackerStore(context: context)
            trackerRecordStore = try TrackerRecordStore(context: context)
            trackerCategoryStore = try TrackerCategoryStore(context: context)
            trackerStore?.delegate = self
            
            categories = trackerCategoryStore?.trackerCategories() ?? []
            filteredCategories = categories 
            
            if let records = try? trackerRecordStore?.trackerRecords() {
                completedTrackers = records
            }
            datePickerValueChanged(datePicker)
        } catch {
            print("Ошибка инициализации TrackerStore: \(error)")
        }
    }
    
    private func showContentOrPlaceholder() {
        let hasTrackers = visibleCategories.contains { !$0.trackers.isEmpty }
        collectionView.isHidden = !hasTrackers
        firstTrackerImageView.isHidden = hasTrackers
        imageTextLabel.isHidden = hasTrackers
        
        collectionView.reloadData()
    }
    
    func addNewTracker(_ tracker: Tracker, to category: TrackerCategory) {
        do {
            let currentCategories = trackerCategoryStore?.trackerCategories() ?? []
            
            if let index = currentCategories.firstIndex(where: { $0.header == category.header }) {
                let existingCategory = currentCategories[index]
                let updatedTrackers = existingCategory.trackers + [tracker]
                let updatedCategory = TrackerCategory(header: existingCategory.header, trackers: updatedTrackers)
                try trackerCategoryStore?.updateCategory(updatedCategory)
            } else {
                let newCategory = TrackerCategory(header: category.header, trackers: [tracker])
                try trackerCategoryStore?.addTrackerCategory(newCategory)
            }
            
            categories = trackerCategoryStore?.trackerCategories() ?? []
            datePickerValueChanged(datePicker)
            
        } catch {
            print("Ошибка при добавлении трекера: \(error)")
        }
    }
    
    private func updateNumberOfDays(_ tracker: Tracker) {
        
        guard datePicker.date <= currentDate else { return }
        
        let existingIndex = completedTrackers.firstIndex {
            $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: self.datePicker.date)
        }
        if let index = existingIndex {
            let record = completedTrackers[index]
            completedTrackers.remove(at: index)
            if let recordCoreData = try? trackerRecordStore?.record(for: record) {
                try? trackerRecordStore?.deleteRecord(recordCoreData)
            }
        } else {
            completedTrackers.append(TrackerRecord(id: tracker.id, date: datePicker.date))
            try? trackerRecordStore?.addTrackerRecord(TrackerRecord(id: tracker.id, date: datePicker.date))
        }
    }
    
    private func updateVisibleCategories(for date: Date) {
        let selectedWeekdayIndex = Calendar.current.component(.weekday, from: date)
        let weekDaysOrdered: [WeekDay] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        let selectedWeekday = weekDaysOrdered[selectedWeekdayIndex - 1]

        let pinnedTrackers = categories.flatMap { $0.trackers }.filter { $0.isPinned }

        var newCategories: [TrackerCategory] = []

        if !pinnedTrackers.isEmpty {
            newCategories.append(
                TrackerCategory(header: NSLocalizedString("pinned.category.title", comment: ""), trackers: pinnedTrackers)
            )
        }

        let nonPinnedCategories = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                guard !tracker.isPinned else { return false }

                if let schedule = tracker.schedule, !schedule.isEmpty {
                    return schedule.contains(selectedWeekday)
                } else {
                    let wasMarked = completedTrackers.contains { $0.id == tracker.id }
                    if wasMarked {
                        return completedTrackers.contains {
                            $0.id == tracker.id &&
                            Calendar.current.isDate($0.date, inSameDayAs: date)
                        }
                    } else {
                        return true
                    }
                }
            }
            return TrackerCategory(header: category.header, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }

        newCategories += nonPinnedCategories

        visibleCategories = newCategories

        showContentOrPlaceholder()
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
            
            addTracker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 13),
            addTracker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            
            trackerLabel.topAnchor.constraint(equalTo: addTracker.bottomAnchor, constant: 13),
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
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.cellIdentifier, for: indexPath) as? TrackerCell
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
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
        
        header.headerLabel.text = visibleCategories[indexPath.section].header
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

extension TrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell else {
            return nil
        }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        
        return UITargetedPreview(view: cell.cellBackground, parameters: parameters)
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { [weak self] _ in
            
            let pinTitle = tracker.isPinned ? NSLocalizedString("context.menu.unpin", comment: "") : NSLocalizedString("context.menu.pin", comment: "")
            let pinAction = UIAction(title: pinTitle) { _ in
                do {
                    try self?.trackerStore?.togglePin(for: tracker)
                } catch {
                    print("Ошибка togglePin: \(error)")
                }
            }
            
            let tracker = self?.visibleCategories[indexPath.section].trackers[indexPath.item]
            let category = self?.visibleCategories[indexPath.section]

            let editAction = UIAction(title: NSLocalizedString("context.menu.edit", comment: "")) { [weak self] _ in
                guard let self = self, let tracker = tracker, let category = category else { return }

                let habitVC = CreateNewHabitViewController()
                habitVC.editingMode = .edit(tracker, category)
                habitVC.trackerRecordStore = self.trackerRecordStore
                habitVC.onCreateTracker = { [weak self] updatedTracker, updatedCategory in
                    try? self?.trackerStore?.updateTracker(updatedTracker, inCategoryWithHeader: updatedCategory.header)
                }
                self.present(habitVC, animated: true)
            }
            
            let deleteAction = UIAction(title: NSLocalizedString("context.menu.delete", comment: ""), attributes: .destructive) { [weak self] _ in
                guard let self = self, let tracker = tracker else { return }

                let alert = UIAlertController(
                    title: nil,
                    message: NSLocalizedString("delete.confirmation.message", comment: ""),
                    preferredStyle: .actionSheet
                )

                let confirmAction = UIAlertAction(title: NSLocalizedString("delete.confirm", comment: ""), style: .destructive) { _ in
                    do {
                        try self.trackerStore?.deleteTracker(tracker)
                    } catch {
                        print("Ошибка deleteTracker: \(error)")
                    }
                }

                let cancelAction = UIAlertAction(title: NSLocalizedString("delete.cancel", comment: ""), style: .cancel, handler: nil)

                alert.addAction(confirmAction)
                alert.addAction(cancelAction)

                self.present(alert, animated: true)
            }
            
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }
}

extension TrackerViewController: TrackerStoreDelegate {
    func store(_ store: TrackerStore, didUpdate update: TrackerStoreUpdate) {
        categories = trackerCategoryStore?.trackerCategories() ?? []
        updateVisibleCategories(for: datePicker.date)
        collectionView.reloadData()
    }
}

