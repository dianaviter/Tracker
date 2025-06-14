//
//  TabBarController.swift
//  Tracker
//
//  Created by Diana Viter on 28.03.2025.
//

import UIKit

final class TabBarController: UITabBarController {
    
    private var tabBarSeparator: UIView?
    
    override func viewDidLoad () {
        super.viewDidLoad()
        
        let trackerViewController = TrackerViewController()
        trackerViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("trackerview.title", comment: ""),
            image: UIImage(named: "trackersTabBarIcon"),
            selectedImage: nil
        )
        
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tabbar.statistics.title", comment: ""),
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
        tabBar.backgroundColor = .trackerWhite
        
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            separator.topAnchor.constraint(equalTo: tabBar.topAnchor)
        ])
        
        tabBarSeparator = separator
    }
    
    func updateSeparatorColor() {
        if traitCollection.userInterfaceStyle == .dark {
            tabBarSeparator?.backgroundColor = .clear
        } else {
            tabBarSeparator?.backgroundColor = .trackerGray
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateSeparatorColor()
    }
}
