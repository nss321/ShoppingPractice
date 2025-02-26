//
//  DateManager.swift
//  ShoppingPractice
//
//  Created by BAE on 2/26/25.
//

import Foundation

final class DateManager {
    static let shared = DateManager()
    
    private let formatter: DateFormatter
    
    private init() {
        formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
    }
    
    func dateFormat(date: Date) -> String {
        return formatter.string(from: date)
    }
}
