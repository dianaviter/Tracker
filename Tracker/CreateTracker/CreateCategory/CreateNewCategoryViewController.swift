//
//  CreateNewCategoryViewController.swift
//  Tracker
//
//  Created by Diana Viter on 10.05.2025.
//

import UIKit

final class CreateNewCategoryViewController: UIViewController {
    
    // MARK: - Properties
    
    var onCategoryCreated: ((TrackerCategory) -> Void)?
    var trackerCategoryStore: TrackerCategoryStore?
    
    // MARK: - UI Elements
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("createcategory.title", comment: "")
        label.textColor = .trackerBlack
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let categoryNameTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("createcategory.name.placeholder", comment: ""),
            attributes: [
                .foregroundColor: UIColor.lightGray,
                .font: UIFont.systemFont(ofSize: 17, weight: .regular)
            ]
        )
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.layer.cornerRadius = 16
        textField.clipsToBounds = true
        textField.backgroundColor = .trackerBackground
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        return textField
    }()
    
    private let createButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("createcategory.done.button", comment: ""), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .trackerGray
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        return button
    }()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .trackerWhite
        
        categoryNameTextField.addTarget(self, action: #selector(categoryNameTextFieldDidChange(_:)), for: .editingChanged)
        createButton.addTarget(self, action: #selector(createButtonTapped(_:)), for: .touchUpInside)
        
        setUpConstraints()
    }
    
    // MARK: - Actions
    
    @objc private func categoryNameTextFieldDidChange(_ textField: UITextField) {
        activateCreateButton()
    }
    
    @objc private func createButtonTapped(_ button: UIButton) {
        guard let categoryName = categoryNameTextField.text else { return }

        let newCategory = TrackerCategory(header: categoryName, trackers: [])

        do {
            try trackerCategoryStore?.addTrackerCategory(newCategory)
            onCategoryCreated?(newCategory)
        } catch {
            print("Ошибка сохранения категории: \(error)")
        }

        dismiss(animated: true)
    }
    
    // MARK: - Layout
    
    private func setUpConstraints() {
        [textLabel, categoryNameTextField, createButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            categoryNameTextField.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 38),
            categoryNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            createButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Private methods
    
    private func activateCreateButton() {
        let name = categoryNameTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        
        if !name.isEmpty {
            createButton.isEnabled = true
            createButton.setTitleColor(.trackerWhite, for: .normal)
            createButton.backgroundColor = .trackerBlack
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = .trackerGray
        }
    }
}
