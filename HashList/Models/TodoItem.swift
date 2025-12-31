//
//  TodoItem.swift
//  HashList
//
//  Created by Shubhdeep Sarkar on 12/31/24.
//

import Foundation
import SwiftData

@Model
final class TodoItem {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var order: Int
    var createdDate: Date
    var dueDate: Date?
    var list: TodoList?
    
    init(title: String, order: Int = 0, isCompleted: Bool = false) {
        self.id = UUID()
        self.title = title
        self.isCompleted = isCompleted
        self.order = order
        self.createdDate = Date()
        self.dueDate = nil
    }
}
