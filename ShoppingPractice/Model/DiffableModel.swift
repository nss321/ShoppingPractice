//
//  DiffableModel.swift
//  ShoppingPractice
//
//  Created by BAE on 2/26/25.
//

import Foundation

struct DiffableModel: Hashable {
    let uuid = UUID()
    let image: String
    let content: String
    private let _date: Date
    var date: String {
        return DateManager.shared.dateFormat(date: _date)
    }
    
    init(image: String, content: String, date: Date) {
        self.image = image
        self.content = content
        self._date = date
    }
    
    static func mockData() -> [DiffableModel] {
        return [
            DiffableModel.init(image: "star.fill", content: "star.fill", date: .now),
            DiffableModel.init(image: "paperplane.fill", content: "paperplane.fill", date: .now),
            DiffableModel.init(image: "book.fill", content: "book.fill", date: .now),
            DiffableModel.init(image: "baseball.fill", content: "baseball.fill", date: .now),
            DiffableModel.init(image: "trophy.fill", content: "trophy.fill", date: .now),
            DiffableModel.init(image: "sunrise.fill", content: "sunrise.fill", date: .now),
        ]
    }
    
    static func mockData2() -> [DiffableModel] {
        return [
            DiffableModel.init(image: "star", content: "star", date: .now),
            DiffableModel.init(image: "paperplane", content: "paperplane", date: .now),
            DiffableModel.init(image: "book", content: "book", date: .now),
            DiffableModel.init(image: "baseball", content: "baseball", date: .now),
            DiffableModel.init(image: "trophy", content: "trophy", date: .now),
            DiffableModel.init(image: "sunrise", content: "sunrise", date: .now),
        ]
    }
    
    
}


