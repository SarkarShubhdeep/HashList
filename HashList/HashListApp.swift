//
//  HashListApp.swift
//  HashList
//
//  Created by Shubhdeep Sarkar on 12/30/25.
//

import SwiftUI
import SwiftData

@main
struct HashListApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: TodoList.self)
    }
}
