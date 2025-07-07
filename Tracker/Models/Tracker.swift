//
//  Untitled.swift
//  Tracker
//
//  Created by Diana Viter on 15.04.2025.
//

import UIKit

struct Tracker {
    let id: UUID
    let name: String?
    let color: UIColor?
    let emoji: String?
    let schedule: Set<WeekDay>?
    var isPinned: Bool
}
