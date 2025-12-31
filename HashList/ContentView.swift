//
//  ContentView.swift
//  HashList
//
//  Created by Shubhdeep Sarkar on 12/30/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TodoList.createdDate, order: .forward) private var todoLists: [TodoList]
    
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
                                TodoListCard(
                                    list: list,
                                    onDelete: { deleteList(list) },
                                    onRename: { newName in renameList(list, newName: newName) }
                                )
                            }
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: 1200)
                }
            }
            
            // Fixed Header Card
            HeaderCard(onAddList: addNewList)
                .padding(20)
                .frame(height: 100, alignment: .top)
                .frame(maxWidth: 1200)
        }
        .frame(minWidth: 600, minHeight: 400)
    }
    
    // MARK: - Data Operations
    
    private func addNewList() {
        let newList = TodoList(name: "New List")
        modelContext.insert(newList)
        try? modelContext.save()
    }
    
    private func deleteList(_ list: TodoList) {
        modelContext.delete(list)
        try? modelContext.save()
    }
    
    private func renameList(_ list: TodoList, newName: String) {
        list.name = newName
        try? modelContext.save()
    }
}

struct HeaderCard: View {
    let onAddList: () -> Void
    
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
                    Button(action: onAddList) {
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
    let onDelete: () -> Void
    let onRename: (String) -> Void
    
    @State private var isHovered = false
    @State private var isEditing = false
    @State private var editedName: String = ""
    @State private var showMenu = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("\(list.taskCount) tasks")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if isHovered {
                    Menu {
                        Button("Rename") {
                            startEditing()
                        }
                        
                        Button("Archive") {
                            // TODO: Implement archive functionality
                        }
                        
                        Divider()
                        
                        Button("Delete", role: .destructive) {
                            onDelete()
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .frame(width: 24, height: 24)
                    }
                    .menuStyle(.borderlessButton)
                    .fixedSize()
                }
            }
            
            Spacer()
            
            if isEditing {
                TextField("List name", text: $editedName)
                    .font(.system(size: 16, weight: .medium))
                    .textFieldStyle(.plain)
                    .focused($isTextFieldFocused)
                    .onSubmit {
                        saveEdit()
                    }
                    .onExitCommand {
                        cancelEdit()
                    }
            } else {
                Text(list.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
            }
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
            if isEditing {
                saveEdit()
            } else {
                // Open list action
            }
        }
    }
    
    private func startEditing() {
        editedName = list.name
        isEditing = true
        // Focus the text field after a brief delay to ensure it's rendered
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isTextFieldFocused = true
        }
    }
    
    private func saveEdit() {
        if !editedName.isEmpty {
            onRename(editedName)
        }
        isEditing = false
        isTextFieldFocused = false
    }
    
    private func cancelEdit() {
        isEditing = false
        isTextFieldFocused = false
        editedName = list.name
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TodoList.self, inMemory: true)
}
