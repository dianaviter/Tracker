//
//  ScheduleMarchalling.swift
//  Tracker
//
//  Created by Diana Viter on 25.04.2025.
//

import Foundation

final class ScheduleMarshalling {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func data(from schedule: Set<WeekDay>) -> Data? {
        return try? encoder.encode(schedule)
    }
    
    func schedule(from data: Data?) -> Set<WeekDay>? {
        guard let data else { return nil }
        return try? decoder.decode(Set<WeekDay>.self, from: data)
    }
}
