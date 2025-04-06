//
//  CreateTracker.swift
//  Tracker
//
//  Created by Diana Viter on 06.04.2025.
//

import UIKit

final class CreateTrackerViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpConstraints()
    }

    private func setUpConstraints() {
        [habitButton, irregularEventButton, textLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(habitButton)
        view.addSubview(irregularEventButton)
        view.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 78),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 114),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -112),
            
            habitButton.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 281),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            irregularEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            irregularEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            irregularEventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            irregularEventButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 281)
        ])
    }
    
    let habitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .trackerBlack
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.setTitle("Привычка", for: .normal)
        button.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 16)
        button.titleLabel?.textColor = .white
        return button
    }()
    
    let irregularEventButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .trackerBlack
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.setTitle("Нерегулярное событие", for: .normal)
        button.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 16)
        button.titleLabel?.textColor = .white
        return button
    }()
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.text = "Создание трекера"
        label.textColor = .white
        label.font = UIFont(name: "YSDisplay-Medium", size: 16)
        return label
    }()
}
