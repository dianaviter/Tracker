//
//  CreateTracker.swift
//  Tracker
//
//  Created by Diana Viter on 06.04.2025.
//

import UIKit

final class CreateTrackerViewController: UIViewController {
    
    var onTrackerCreated: ((Tracker, TrackerCategory) -> Void)?
    var trackerCategoryStore: TrackerCategoryStore?
    
    let habitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .trackerBlack
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.setTitle(NSLocalizedString("create.tracker.habit.button", comment: ""), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = .white
        return button
    }()
    
    let irregularEventButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .trackerBlack
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.setTitle(NSLocalizedString("create.tracker.irregularevent.button", comment: ""), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = .white
        return button
    }()
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("createtracker.title", comment: "")
        label.textColor = .trackerBlack
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpConstraints()
        view.backgroundColor = .white
        habitButton.addTarget(self, action: #selector(createHabitButtonTapped(_:)), for: .touchUpInside)
        irregularEventButton.addTarget(self, action: #selector(createIrregularEventButtonTapped(_:)), for: .touchUpInside)
    }
    
    @objc func createHabitButtonTapped(_ sender: UIButton) {
        let habitVC = CreateNewHabitViewController()
        habitVC.onCreateTracker = { [weak self] tracker, category in
            self?.onTrackerCreated?(tracker, category)
            self?.presentingViewController?.dismiss(animated: true)
        }
        present(habitVC, animated: true)
    }
    
    @objc func createIrregularEventButtonTapped(_ sender: UIButton) {
        let irregularEventVC = CreateIrregularEventViewController()
        irregularEventVC.onCreateTracker = { [weak self] tracker, category in
            self?.onTrackerCreated?(tracker, category)
            self?.presentingViewController?.dismiss(animated: true)
        }
        present(irregularEventVC, animated: true)
    }
    
    private func setUpConstraints() {
        [habitButton, irregularEventButton, textLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(habitButton)
        view.addSubview(irregularEventButton)
        view.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            habitButton.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 295),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            
            irregularEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            irregularEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            irregularEventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
