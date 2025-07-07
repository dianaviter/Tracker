//
//  FilterViewController.swift
//  Tracker
//
//  Created by Diana Viter on 14.06.2025.
//

import UIKit

enum TrackerFilter: String, CaseIterable {
    case all
    case today
    case completed
    case notCompleted
    
    var title: String {
        switch self {
        case .all:
            return NSLocalizedString("tracker.filter.all", comment: "")
        case .today:
            return NSLocalizedString("tracker.filter.today", comment: "")
        case .completed:
            return NSLocalizedString("tracker.filter.completed", comment: "")
        case .notCompleted:
            return NSLocalizedString("tracker.filter.notCompleted", comment: "")
        }
    }
}

final class FiltersViewController: UIViewController {
    
    var selectedFilter: TrackerFilter = .all
    var onFilterSelected: ((TrackerFilter) -> Void)?
    
    private let filters = TrackerFilter.allCases
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("filter.title", comment: "")
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .trackerBlack
        label.textAlignment = .center
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        let backgroundView = UIView()
        backgroundView.backgroundColor = .trackerBackground
        tableView.backgroundView = backgroundView
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .trackerGray
        tableView.rowHeight = 75
        return tableView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .trackerWhite
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "filterCell")
        
        setupLayout()
    }
    
    private func setupLayout() {
        [titleLabel, tableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(filters.count * 75))
        ])
    }
}

// MARK: - UITableViewDataSource

extension FiltersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let filter = filters[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath)
        
        cell.textLabel?.text = filter.title
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.textLabel?.textColor = .trackerBlack
        cell.backgroundColor = .trackerBackground

        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        cell.accessoryType = filter == selectedFilter ? .checkmark : .none
        
        if indexPath.row == filters.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFilter = filters[indexPath.row]
        onFilterSelected?(selectedFilter)
        dismiss(animated: true)
    }
}
