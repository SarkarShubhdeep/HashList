//
//  ContentView.swift
//  HashList
//
//  Created by Shubhdeep Sarkar on 12/30/25.
//

import SwiftUI

struct TodoList: Identifiable {
    let id = UUID()
    let name: String
    let taskCount: Int
}

struct ContentView: View {
    @State private var todoLists = [
        TodoList(name: "Challenges", taskCount: 3),
        TodoList(name: "Daily Todo", taskCount: 8),
        TodoList(name: "Academics", taskCount: 12),
        TodoList(name: "Groceries", taskCount: 5),
        TodoList(name: "Work", taskCount: 3),
        TodoList(name: "Chores", taskCount: 5),
        TodoList(name: "Reminders", taskCount: 9),
        TodoList(name: "Other", taskCount: 2)
    ]
    
    let columns = [
        GridItem(.adaptive(minimum: 200, maximum: 250), spacing: 16)
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 84)
                    
                    VStack(spacing: 24) {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(todoLists) { list in
                                TodoListCard(list: list)
                            }
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: 1200)
                }
            }
            
            // Fixed Header Card
            HeaderCard()
                .padding(20)
                .frame(height: 100, alignment: .top)
                .frame(maxWidth: 1200)
        }
        .frame(minWidth: 600, minHeight: 400)
    }
}

struct HeaderCard: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background with blur effect
            Color.white.opacity(0.1)
                .background(.ultraThinMaterial)
            
            // Soft border
            Rectangle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            
            // Content
            HStack {
                Text("HashList")
                    .font(.system(size: 18, weight: .semibold))
                
                Spacer()
                HStack(spacing: 16) {
                    Button(action: {}) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 14))
                            Text("Add List")
                                .font(.system(size: 14))
                        }
                        .frame(height: 32)
                        .padding(.horizontal, 12)
                        .background(Color.white.opacity(0.2))
                    }
                    .buttonStyle(.plain)
                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 14))
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.2))
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {}) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 14))
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.2))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
        
    }
}

struct NewListCard: View {
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "plus")
                .font(.system(size: 24))
                .foregroundColor(.gray)
            
            Text("New List")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(Color.gray.opacity(isHovered ? 0.08 : 0.03))
        .overlay(
            Rectangle()
                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                .foregroundColor(.gray.opacity(0.3))
        )
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            // Add new list action
        }
    }
}

struct TodoListCard: View {
    let list: TodoList
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(list.taskCount) tasks")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(list.name)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 120)
        .background(Color.gray.opacity(isHovered ? 0.12 : 0.06))
        .overlay(
            Rectangle()
                .stroke(Color.gray.opacity(isHovered ? 0.3 : 0.15), lineWidth: 1)
        )
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            // Open list action
        }
    }
}

#Preview {
    ContentView()
}
