//
//  BillableHelper.swift
//  Freelancer
//
//  Created by John Haselden on 23/08/2025.
//

import Foundation

class BillableHelper {
    func numberOfSegments(for interval: Rate.TimeInterval, between startDate: Date, and endDate: Date) -> Int {
        switch interval {
        case .minute:
            let components = Calendar.current.dateComponents([.minute], from: startDate, to: endDate)

            if let minutes = components.minute {
                return minutes
            } else {
                return 0
            }
        case .hour:
            let components = Calendar.current.dateComponents([.hour], from: startDate, to: endDate)

            if let hours = components.hour {
                return hours
            } else {
                return 0
            }
        case .day:
            let components = Calendar.current.dateComponents([.day], from: startDate, to: endDate)

            if let day = components.day {
                return day
            } else {
                return 0
            }

        }
        
    }
}
