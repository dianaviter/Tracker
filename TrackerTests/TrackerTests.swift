//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Diana Viter on 16.06.2025.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerViewSnapshotTests: XCTestCase {

    func testMainViewController_Light() {
        let vc = TrackerViewController()
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    func testMainViewController_Dark() {
        let vc = TrackerViewController()
        assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}


