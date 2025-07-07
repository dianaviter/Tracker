//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Diana Viter on 07.04.2025.
//

import UIKit

// MARK: - Models

enum WeekDay: String, CaseIterable, Codable {
    case monday = "monday"
    case tuesday = "tuesday"
    case wednesday = "wednesday"
    case thursday = "thursday"
    case friday = "friday"
    case saturday = "saturday"
    case sunday = "sunday"
    
    var fullName: String {
        return NSLocalizedString("weekday.full.\(self.rawValue)", comment: "")
    }

    var shortName: String {
        return NSLocalizedString("weekday.short.\(self.rawValue)", comment: "")
    }
}

// MARK: - View Controller

final class ScheduleViewController: UIViewController {
    
    // MARK: - Properties
    
    let cellIdentifier = "cell"
    var selectedWeekDays: Set<WeekDay> = []
    var daysSelected: (([WeekDay]) -> Void)?
    
    // MARK: - UI elements
    
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
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("scheduleview.title", comment: "")
        label.textColor = .trackerBlack
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("scheduleview.done.button", comment: ""), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.trackerWhite, for: .normal)
        button.backgroundColor = .trackerBlack
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .trackerWhite
        tableView.dataSource = self
        setUpConstraints()
        doneButton.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc func switchToggled(_ sender: UISwitch) {
        let day = WeekDay.allCases[sender.tag]
        
        if sender.isOn {
            selectedWeekDays.insert(day)
        } else {
            selectedWeekDays.remove(day)
        }
    }
    
    @objc func doneButtonTapped(_ sender: UIButton) {
        daysSelected?(Array(selectedWeekDays))
        dismiss(animated: true)
    }
    
    // MARK: - Layout
    
    private func setUpConstraints() {
        [tableView, textLabel, doneButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(tableView)
        view.addSubview(textLabel)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525),
            
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
}

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WeekDay.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        cell.textLabel?.text = WeekDay.allCases[indexPath.row].fullName
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = .trackerBlack
        cell.backgroundColor = .trackerBackground
        
        let toggle = UISwitch()
        toggle.isOn = selectedWeekDays.contains(WeekDay.allCases[indexPath.row])
        toggle.tag = indexPath.row
        toggle.backgroundColor = .white
        toggle.clipsToBounds = true
        toggle.layer.cornerRadius = 16
        toggle.onTintColor = .trackerBlue
        toggle.addTarget(self, action: #selector(switchToggled(_:)), for: .valueChanged)
        
        cell.accessoryView = toggle
        
        if indexPath.row == WeekDay.allCases.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        return cell
    }
}

