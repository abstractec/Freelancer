//
//  BillableHelper.swift
//  Freelancer
//
//  Created by John Haselden on 23/08/2025.
//

import Foundation

class BillableHelper {
    func amount(for billable: Billable) -> Double {
        if billable.kind == .fixed {
            return billable.fixedAmount
        }
        
        guard let rate = billable.rate else {
            return 0
        }
        
        if rate.timeUnit == 0 {
            return Double(rate.amount)
        }
        
        let interval = numberOfSegments(for: rate.timeInterval, between: billable.start, and: billable.end)
        return Double((interval * rate.amount) / rate.timeUnit)
    }
    
    func currency(for billable: Billable) -> String {
        if billable.kind == .fixed {
            return billable.currency
        }
        
        return billable.rate?.currency ?? ""
    }
    
    func currency(for billables: [Billable]) -> String {
        guard let first = billables.first else {
            return ""
        }
        
        return currency(for: first)
    }
    
    func formattedAmount(for billable: Billable) -> String {
        let currency = currency(for: billable)
        let amountText = String(format: "%.2f", amount(for: billable))
        
        if currency.isEmpty {
            return amountText
        }
        
        return "\(currency) \(amountText)"
    }
    
    func rateLabel(for billable: Billable) -> String {
        if billable.kind == .fixed {
            return "Fixed"
        }
        
        return billable.rate?.name ?? ""
    }
    
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
