//
//  TabBarController.swift
//  Tracker
//
//  Created by Diana Viter on 28.03.2025.
//

import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad () {
        super.viewDidLoad()

        let trackerViewController = TrackerViewController()
        trackerViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "trackersTabBarIcon"),
            selectedImage: nil
        )
    
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "statisticsTabBarIcon"),
            selectedImage: nil)
        
        self.viewControllers = [trackerViewController, statisticsViewController]
        setUpSeparator()
    }
    
    func setUpSeparator() {
        let separator = UIView()
        separator.backgroundColor = .trackerGray
        separator.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            separator.topAnchor.constraint(equalTo: tabBar.topAnchor)
        ])
    }
}
