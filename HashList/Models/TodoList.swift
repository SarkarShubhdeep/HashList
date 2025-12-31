//
//  TodoList.swift
//  HashList
//
//  Created by Shubhdeep Sarkar on 12/31/24.
//

import Foundation
import SwiftData

@Model
final class TodoList {
    var id: UUID
    var name: String
    var taskCount: Int
    var createdDate: Date
    
    init(name: String, taskCount: Int = 0) {
        self.id = UUID()
        self.name = name
        self.taskCount = taskCount
        self.createdDate = Date()
    }
}
