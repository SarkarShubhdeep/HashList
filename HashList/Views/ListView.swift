//
//  ListView.swift
//  HashList
//
//  Created by Shubhdeep Sarkar on 12/31/24.
//

import SwiftUI
import SwiftData

struct ListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    let list: TodoList
    @State private var selectedTaskIds: Set<UUID> = []
    @State private var isEditingListName = false
    @State private var editedListName = ""
    @FocusState private var isListNameFieldFocused: Bool
    
    var sortedItems: [TodoItem] {
        list.items.sorted { $0.order < $1.order }
    }
    
    var hasSelection: Bool {
        !selectedTaskIds.isEmpty
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 140)
                    
                    VStack(spacing: 0) {
                        ForEach(Array(sortedItems.enumerated()), id: \.element.id) { index, task in
                            TaskRow(
                                task: task,
                                isSelected: selectedTaskIds.contains(task.id),
                                onToggleSelection: {
                                    toggleSelection(task.id)
                                },
                                onToggleComplete: {
                                    toggleTaskComplete(task)
                                },
                                onDelete: {
                                    deleteTask(task)
                                },
                                onMoveUp: {
                                    moveTaskUp(index)
                                },
                                onMoveDown: {
                                    moveTaskDown(index)
                                },
                                onRename: { newTitle in
                                    renameTask(task, newTitle: newTitle)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .frame(maxWidth: 1200)
                }
            }
            
            // Fixed Header
            ListHeader(
                listName: list.name,
                isEditingListName: isEditingListName,
                editedListName: $editedListName,
                hasSelection: hasSelection,
                selectedCount: selectedTaskIds.count,
                onBackTap: { dismiss() },
                onListNameTap: startEditingListName,
                onListNameSave: saveListNameEdit,
                onListNameCancel: cancelListNameEdit,
                onAddTask: addTask,
                onBatchDelete: batchDelete,
                onBatchComplete: { batchUpdateStatus(completed: true) },
                onBatchPending: { batchUpdateStatus(completed: false) },
                onDeselectAll: deselectAll
            )
            .padding(20)
            .frame(height: 100, alignment: .topLeading)
            .frame(maxWidth: 1200)
        }
        .frame(minWidth: 600, minHeight: 400)
        .onAppear {
            editedListName = list.name
        }
    }
    
    // MARK: - Actions
    
    private func toggleSelection(_ id: UUID) {
        if selectedTaskIds.contains(id) {
            selectedTaskIds.remove(id)
        } else {
            selectedTaskIds.insert(id)
        }
    }
    
    private func toggleTaskComplete(_ task: TodoItem) {
        task.isCompleted.toggle()
        try? modelContext.save()
    }
    
    private func deleteTask(_ task: TodoItem) {
        modelContext.delete(task)
        selectedTaskIds.remove(task.id)
        updateTaskCount()
        try? modelContext.save()
    }
    
    private func addTask() {
        let newTask = TodoItem(title: "New Task", order: sortedItems.count)
        list.items.append(newTask)
        updateTaskCount()
        try? modelContext.save()
    }
    
    private func updateTaskCount() {
        list.taskCount = list.items.count
    }
    
    private func moveTaskUp(_ index: Int) {
        guard index > 0 else { return }
        let item = sortedItems[index]
        let previousItem = sortedItems[index - 1]
        let temp = item.order
        item.order = previousItem.order
        previousItem.order = temp
        try? modelContext.save()
    }
    
    private func moveTaskDown(_ index: Int) {
        guard index < sortedItems.count - 1 else { return }
        let item = sortedItems[index]
        let nextItem = sortedItems[index + 1]
        let temp = item.order
        item.order = nextItem.order
        nextItem.order = temp
        try? modelContext.save()
    }
    
    private func batchDelete() {
        for id in selectedTaskIds {
            if let item = list.items.first(where: { $0.id == id }) {
                modelContext.delete(item)
            }
        }
        selectedTaskIds.removeAll()
        updateTaskCount()
        try? modelContext.save()
    }
    
    private func batchUpdateStatus(completed: Bool) {
        for id in selectedTaskIds {
            if let item = list.items.first(where: { $0.id == id }) {
                item.isCompleted = completed
            }
        }
        selectedTaskIds.removeAll()
        try? modelContext.save()
    }
    
    private func deselectAll() {
        selectedTaskIds.removeAll()
    }
    
    private func startEditingListName() {
        isEditingListName = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isListNameFieldFocused = true
        }
    }
    
    private func saveListNameEdit() {
        if !editedListName.isEmpty {
            list.name = editedListName
            try? modelContext.save()
        }
        isEditingListName = false
        isListNameFieldFocused = false
    }
    
    private func cancelListNameEdit() {
        isEditingListName = false
        isListNameFieldFocused = false
        editedListName = list.name
    }
    
    private func renameTask(_ task: TodoItem, newTitle: String) {
        if !newTitle.isEmpty {
            task.title = newTitle
            try? modelContext.save()
        }
    }
}

struct ListHeader: View {
    let listName: String
    let isEditingListName: Bool
    @Binding var editedListName: String
    let hasSelection: Bool
    let selectedCount: Int
    let onBackTap: () -> Void
    let onListNameTap: () -> Void
    let onListNameSave: () -> Void
    let onListNameCancel: () -> Void
    let onAddTask: () -> Void
    let onBatchDelete: () -> Void
    let onBatchComplete: () -> Void
    let onBatchPending: () -> Void
    let onDeselectAll: () -> Void
    
    @FocusState private var isFocused: Bool
    
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
                // Back button
                Button(action: onBackTap) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                
                if hasSelection {
                    // Batch operation mode
                    HStack(spacing: 12) {
                        Text("\(selectedCount) selected")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Button(action: onDeselectAll) {
                            Text("Deselect All")
                                .font(.system(size: 14))
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        Button(action: onBatchComplete) {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle")
                                    .font(.system(size: 14))
                                Text("Complete")
                                    .font(.system(size: 14))
                            }
                            .frame(height: 32)
                            .padding(.horizontal, 12)
                            .background(Color.green.opacity(0.2))
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: onBatchPending) {
                            HStack(spacing: 6) {
                                Image(systemName: "clock")
                                    .font(.system(size: 14))
                                Text("Pending")
                                    .font(.system(size: 14))
                            }
                            .frame(height: 32)
                            .padding(.horizontal, 12)
                            .background(Color.orange.opacity(0.2))
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: onBatchDelete) {
                            HStack(spacing: 6) {
                                Image(systemName: "trash")
                                    .font(.system(size: 14))
                                Text("Delete")
                                    .font(.system(size: 14))
                            }
                            .frame(height: 32)
                            .padding(.horizontal, 12)
                            .background(Color.red.opacity(0.2))
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    // Normal mode
                    if isEditingListName {
                        TextField("List name", text: $editedListName)
                            .font(.system(size: 18, weight: .semibold))
                            .textFieldStyle(.plain)
                            .focused($isFocused)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isFocused = true
                                }
                            }
                            .onSubmit {
                                onListNameSave()
                            }
                            .onExitCommand {
                                onListNameCancel()
                            }
                    } else {
                        Text(listName)
                            .font(.system(size: 18, weight: .semibold))
                            .onTapGesture {
                                onListNameTap()
                            }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        Button(action: onAddTask) {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                    .font(.system(size: 14))
                                Text("Add Task")
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
                        
                        Menu {
                            Button("Rename") {
                                onListNameTap()
                            }
                            Button("Sort by Date") {}
                            Button("Sort by Status") {}
                            Divider()
                            Button("Export") {}
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 14))
                                .frame(width: 32, height: 32)
                                .background(Color.white.opacity(0.2))
                        }
                        .menuStyle(.borderlessButton)
                        .menuIndicator(.hidden)
                    }
                }
            }
            .padding(16)
        }
    }
}

struct TaskRow: View {
    let task: TodoItem
    let isSelected: Bool
    let onToggleSelection: () -> Void
    let onToggleComplete: () -> Void
    let onDelete: () -> Void
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void
    let onRename: (String) -> Void
    
    @State private var isHovered = false
    @State private var isEditingTitle = false
    @State private var editedTitle = ""
    @FocusState private var isTitleFieldFocused: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Selection checkbox (visible on hover, blank space otherwise)
            if isHovered {
                Button(action: onToggleSelection) {
                    Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                        .font(.system(size: 18))
                        .foregroundColor(isSelected ? .blue : .secondary)
                }
                .buttonStyle(.plain)
            } else {
                Color.clear
                    .frame(width: 18, height: 18)
            }

            
            // Completion checkbox
            Button(action: onToggleComplete) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(task.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)
            
            // Task title - editable on click
            if isEditingTitle {
                TextField("Task title", text: $editedTitle)
                    .font(.system(size: 14))
                    .textFieldStyle(.plain)
                    .focused($isTitleFieldFocused)
                    .onSubmit {
                        saveEdit()
                    }
                    .onExitCommand {
                        cancelEdit()
                    }
            } else {
                Text(task.title)
                    .frame(maxWidth: .infinity, alignment: .init(horizontal: .leading, vertical: .center))
                    .font(.system(size: 14))
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted)
                    .onTapGesture {
                        startEdit()
                    }
            }
            
            Spacer()
            
            // 3-dots menu (visible on hover)
            if isHovered {
                Menu {
                    Button("Rename") {
                        startEdit()
                    }
                    
                    Button("Move Up") {
                        onMoveUp()
                    }
                    
                    Button("Move Down") {
                        onMoveDown()
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
                .menuIndicator(.hidden)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(isHovered || isSelected ? Color.gray.opacity(0.07) : Color.clear)
        .overlay(
            Rectangle()
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                .frame(height: 1),
            alignment: .bottom
        )
        .onHover { hovering in
            isHovered = hovering
        }
        .contextMenu {
            Button("Rename") {
                startEdit()
            }
            
            Button("Move Up") {
                onMoveUp()
            }
            
            Button("Move Down") {
                onMoveDown()
            }
            
            Divider()
            
            Button("Delete", role: .destructive) {
                onDelete()
            }
        }
    }
    
    private func startEdit() {
        editedTitle = task.title
        isEditingTitle = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isTitleFieldFocused = true
        }
    }
    
    private func saveEdit() {
        onRename(editedTitle)
        isEditingTitle = false
        isTitleFieldFocused = false
    }
    
    private func cancelEdit() {
        isEditingTitle = false
        isTitleFieldFocused = false
        editedTitle = task.title
    }
}

#Preview {
    @Previewable @State var mockList = TodoList(name: "Work Tasks", taskCount: 5)
    ListView(list: mockList)
        .modelContainer(for: TodoList.self, inMemory: true)
        .frame(height: 900)
}
