//
//  YandexMobileMetrica Рудзук.swift
//  Tracker
//
//  Created by Diana Viter on 16.06.2025.
//

import YandexMobileMetrica

enum TrackerEvent: String {
    case open
    case close
    case click
}

enum TrackerItem: String {
    case add_track
    case track
    case filter
    case edit
    case delete
}

func logMainScreenEvent(event: TrackerEvent, item: TrackerItem? = nil) {
    var parameters: [String: Any] = [
        "event": event.rawValue,
        "screen": "Main"
    ]
    if let item = item {
        parameters["item"] = item.rawValue
    }
    
    YMMYandexMetrica.reportEvent("main_screen", parameters: parameters)
    
    print("[LOG] main_screen: \(parameters)")
}
