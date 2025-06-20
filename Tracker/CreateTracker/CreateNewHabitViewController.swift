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
    var onCreateTracker: ((Tracker, TrackerCategory) -> Void)?
    private var tableViewTopConstraint: NSLayoutConstraint?
    let emojiCollection = EmojiCollectionView()
    var selectedEmoji = ""
    let colorCollection = TrackerColorCollectionView()
    var selectedColor = UIColor()
    private var isEmojiSelected = false
    private var isColorSelected = false
    private var selectedCategory: TrackerCategory?
    
    // MARK: - UI Elements
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
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
        label.textAlignment = .center
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
        
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecogniser.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecogniser)
        
        emojiCollection.onEmojiSelected = { [weak self] emoji in
            self?.isEmojiSelected = true
            self?.selectedEmoji = emoji
            self?.activateCreateButton()
        }
        
        colorCollection.onSelectedColor = { [weak self] color in
            self?.isColorSelected = true
            self?.selectedColor = color
            self?.activateCreateButton()
        }
        
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
        let category = selectedCategory ?? defaultCategory
        let newTracker = Tracker(
            id: UUID(),
            name: trackerNameTextField.text,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: Set(selectedDaysInScheduleViewController)
        )
        onCreateTracker?(newTracker, category)
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
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Logic
    
    private func activateCreateButton() {
        let firstLineTableView = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        let secondLineTableView = tableView.cellForRow(at: IndexPath(row: 1, section: 0))
        let name = trackerNameTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        
        if !name.isEmpty
            && firstLineTableView?.detailTextLabel?.text != nil
            && secondLineTableView?.detailTextLabel?.text != nil
            && isEmojiSelected == true
            && isColorSelected == true {
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
            let dayNames = sortedDays.map { $0.shortName }
            cell.detailTextLabel?.text = dayNames.joined(separator: ", ")
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
        activateCreateButton()
    }
    
    private func updateCategory() {
        let indexPath = IndexPath(row: 0, section: 0)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        print ("Selected category: \(selectedCategory?.header ?? "")")
        cell.detailTextLabel?.text = selectedCategory?.header ?? defaultCategory.header
        activateCreateButton()
    }
    
    // MARK: - Layout
    
    private func setUpConstraints() {
        [scrollView, contentView, tableView, textLabel, trackerNameTextField, cancelButton, createButton, errorLabel, colorCollection, emojiCollection].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(textLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(tableView)
        contentView.addSubview(trackerNameTextField)
        contentView.addSubview(cancelButton)
        contentView.addSubview(createButton)
        contentView.addSubview(errorLabel)
        contentView.addSubview(colorCollection)
        contentView.addSubview(emojiCollection)
        
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 24)
        
        if let tableViewTopConstraint = tableViewTopConstraint {
            NSLayoutConstraint.activate([
                textLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
                textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                scrollView.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 14),
                scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                
                contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                
                trackerNameTextField.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
                trackerNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                trackerNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
                
                tableViewTopConstraint,
                tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                tableView.heightAnchor.constraint(equalToConstant: 150),
                
                cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                cancelButton.heightAnchor.constraint(equalToConstant: 60),
                cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -8),
                cancelButton.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -16),
                cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor),
                
                createButton.heightAnchor.constraint(equalToConstant: 60),
                createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                createButton.bottomAnchor.constraint(equalTo: cancelButton.bottomAnchor),
                
                errorLabel.centerXAnchor.constraint(equalTo: trackerNameTextField.centerXAnchor),
                errorLabel.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 8),
                
                emojiCollection.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
                emojiCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
                emojiCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -19),
                emojiCollection.heightAnchor.constraint(equalToConstant: 204),
                emojiCollection.bottomAnchor.constraint(equalTo: colorCollection.topAnchor, constant: -40),

                colorCollection.topAnchor.constraint(equalTo: emojiCollection.bottomAnchor, constant: 14),
                colorCollection.leadingAnchor.constraint(equalTo: emojiCollection.leadingAnchor),
                colorCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -19),
                colorCollection.heightAnchor.constraint(equalToConstant: 220),
                colorCollection.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -40)
            ])
        }
    }
    
    private func updateTableViewConstraint() {
        let indentWithoutError = 24
        let indentWithError = 63
        tableViewTopConstraint?.constant = CGFloat(errorLabel.isHidden ? indentWithoutError : indentWithError)
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
                $0.shortName
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
            cell.detailTextLabel?.text = selectedCategory?.header
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

        if indexPath.row == 0 {
            guard let store = try? TrackerCategoryStore(context: coreDataStack.context) else { return }

            let viewModel = CategoryViewModel(store: store)
            viewModel.fetchCategories()
            
            let vcCategory = CategoryViewController(viewModel: viewModel, selectedCategory: self.selectedCategory)
            
            vcCategory.onCategorySelected = { [weak self] selected in
                self?.selectedCategory = selected
                self?.updateCategory()
                self?.activateCreateButton()
                self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }

            present(vcCategory, animated: true)
        } else {
            let scheduleVC = ScheduleViewController()
            scheduleVC.selectedWeekDays = Set(self.selectedDaysInScheduleViewController)
            scheduleVC.daysSelected = { [weak self] selectedDays in
                self?.selectedDaysInScheduleViewController = selectedDays
                self?.updateScheduleLabel()
            }
            present(scheduleVC, animated: true)
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
