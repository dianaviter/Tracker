//
//  CreateNewHabitViewController.swift
//  Tracker
//
//  Created by Diana Viter on 07.04.2025.
//

import UIKit

final class CreateNewHabitViewController: UIViewController {
    
    // MARK: - Properties
    
    let tableOptions: [String] = ["Категория", "Расписание"]
    let cellIdentifier = "cell"
    private var selectedDaysInScheduleViewController: [WeekDay] = []
    var defaultCategory = TrackerCategory(header: "Все трекеры", trackers: [])
    var onCreateTracker: ((Tracker) -> Void)?
    private var tableViewTopConstraint: NSLayoutConstraint?
    
    // MARK: - UI Elements
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        let backgroundView = UIView()
        backgroundView.backgroundColor = .trackerBackground
        tableView.backgroundView = backgroundView
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = 75
        return tableView
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.textColor = .trackerBlack
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let trackerNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.layer.cornerRadius = 16
        textField.clipsToBounds = true
        textField.backgroundColor = .trackerBackground
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        return textField
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.setTitleColor(.trackerRed, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.trackerRed.cgColor
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = .white
        button.backgroundColor = .trackerGray
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        return button
    }()
    
    private let clearButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .trackerGray
        button.isHidden = true
        button.contentHorizontalAlignment = .right
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 17, bottom: 0, right: 12)
        return button
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .trackerRed
        label.isHidden = true
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUpConstraints()
        tableView.dataSource = self
        tableView.delegate = self
        trackerNameTextField.delegate = self
        clearButton.frame = CGRect(x: 0, y: 0, width: 17, height: 17)
        trackerNameTextField.rightView = clearButton
        trackerNameTextField.rightViewMode = .always
        
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped(_:)), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonTapped(_:)), for: .touchUpInside)
        trackerNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func createButtonTapped(_ sender: UIButton) {
        let newTracker = Tracker(
            id: UUID(),
            name: trackerNameTextField.text,
            color: .trackerRed,
            emoji: "🙂",
            schedule: Set(selectedDaysInScheduleViewController)
        )
        onCreateTracker?(newTracker)
        dismiss(animated: true)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        activateCreateButton()
        clearButton.isHidden = false
    }
    
    @objc private func clearButtonTapped() {
        trackerNameTextField.text = ""
        clearButton.isHidden = true
        errorLabel.isHidden = true
        updateTableViewConstraint()
    }
    
    // MARK: - Logic
    
    private func activateCreateButton() {
        let firstLineTableView = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        let secondLineTableView = tableView.cellForRow(at: IndexPath(row: 1, section: 0))
        let name = trackerNameTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        
        if !name.isEmpty && firstLineTableView?.detailTextLabel?.text != nil && secondLineTableView?.detailTextLabel?.text != nil {
            createButton.isEnabled = true
            createButton.backgroundColor = .trackerBlack
            createButton.titleLabel?.textColor = .trackerWhite
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = .trackerGray
        }
    }
    
    private func sortDays(_ days: [WeekDay]) -> [WeekDay] {
        return days.sorted {
            guard let firstIndex = WeekDay.allCases.firstIndex(of: $0),
                  let secondIndex = WeekDay.allCases.firstIndex(of: $1) else {
                return false
            }
            return firstIndex < secondIndex
        }
    }
    
    private func updateScheduleLabel() {
        let sortedDays = sortDays(selectedDaysInScheduleViewController)
        
        let indexPath = IndexPath(row: 1, section: 0)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        if selectedDaysInScheduleViewController.isEmpty {
            cell.detailTextLabel?.text = nil
        } else {
            let dayNames = sortedDays.map {
                switch $0 {
                case .monday: "Пн"
                case .tuesday: "Вт"
                case .wednesday: "Ср"
                case .thursday: "Чт"
                case .friday: "Пт"
                case .saturday: "Сб"
                case .sunday: "Вс"
                }
            }
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
        activateCreateButton()
    }
    
    private func updateCategory() {
        let indexPath = IndexPath(row: 0, section: 0)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.detailTextLabel?.text = defaultCategory.header
        activateCreateButton()
    }
    
    // MARK: - Layout
    
    private func setUpConstraints() {
        [tableView, textLabel, trackerNameTextField, cancelButton, createButton, errorLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(tableView)
        view.addSubview(trackerNameTextField)
        view.addSubview(textLabel)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        view.addSubview(errorLabel)
        
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 24)
        
        if let tableViewTopConstraint = tableViewTopConstraint {
            NSLayoutConstraint.activate([
                textLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
                textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                trackerNameTextField.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 38),
                trackerNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                trackerNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
                
                tableViewTopConstraint,
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                tableView.heightAnchor.constraint(equalToConstant: 150),
                
                cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                cancelButton.heightAnchor.constraint(equalToConstant: 60),
                cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -8),
                cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor),
                
                createButton.heightAnchor.constraint(equalToConstant: 60),
                createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                createButton.bottomAnchor.constraint(equalTo: cancelButton.bottomAnchor),
                
                errorLabel.centerXAnchor.constraint(equalTo: trackerNameTextField.centerXAnchor),
                errorLabel.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 8)
            ])
        }
    }
    
    private func updateTableViewConstraint() {
        tableViewTopConstraint?.constant = errorLabel.isHidden ? 24 : 63
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITableViewDataSource

extension CreateNewHabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        cell.textLabel?.text = tableOptions[indexPath.row]
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = .black
        cell.backgroundColor = .trackerBackground
        cell.accessoryType = .disclosureIndicator
        
        let sortedDays = sortDays(selectedDaysInScheduleViewController)
        if indexPath.row == 1 && !sortedDays.isEmpty {
            let dayNames = sortedDays.map {
                switch $0 {
                case .monday: "Пн"
                case .tuesday: "Вт"
                case .wednesday: "Ср"
                case .thursday: "Чт"
                case .friday: "Пт"
                case .saturday: "Сб"
                case .sunday: "Вс"
                }
            }
            if WeekDay.allCases.count == sortedDays.count {
                cell.detailTextLabel?.text = "Каждый день"
            } else {
                cell.detailTextLabel?.text = dayNames.joined(separator: ", ")
            }
        }
        cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.detailTextLabel?.textColor = .trackerGray
        if indexPath.row == 0 {
            cell.detailTextLabel?.text = defaultCategory.header
        }
        
        if indexPath.row == tableOptions.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CreateNewHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vcCategory = CategoryViewController()
        let vcSchedule = ScheduleViewController()
        
        if indexPath.row == 0 {
            present(vcCategory, animated: true)
        } else {
            present(vcSchedule, animated: true)
            vcSchedule.selectedWeekDays = Set(selectedDaysInScheduleViewController)
            vcSchedule.daysSelected = { [weak self] selected in
                self?.selectedDaysInScheduleViewController = selected
                self?.updateScheduleLabel()
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension CreateNewHabitViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text,
              let stringRange = Range(range, in: currentText) else {
            return true
        }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        let isTooLong = updatedText.count > 38
        if isTooLong {
            errorLabel.isHidden = false
            updateTableViewConstraint()
        } else {
            errorLabel.isHidden = true
            updateTableViewConstraint()
        }
        return !isTooLong
    }
}
