//
//  ContentView.swift
//  SwiftUIToDoList
//
//  Created by Simon Ng on 28/7/2023.
//

import SwiftUI
import SwiftData

struct ContentView: View {
        
    @Query(sort: \ToDoItem.priorityNum, order: .reverse) var todoItems: [ToDoItem] = []
    
    @State private var newItemName: String = ""
    @State private var newItemPriority: Priority = .normal
    
    @State private var showNewTask = false
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                VStack {
                    List {
                        
                        ForEach(todoItems) { todoItem in
                            ToDoListRow(todoItem: todoItem)
                        }
                        .onDelete(perform: deleteTask)
                        
                    }
                    .listStyle(.plain)
                    
                }
                
                // If there is no data, show an empty view
                if todoItems.count == 0 {
                    NoDataView()
                }
                
                // Display the "Add new todo" view
                if showNewTask {
                    BlankView(bgColor: .black)
                        .opacity(0.5)
                        .onTapGesture {
                            self.showNewTask = false
                        }
                    
                    NewToDoView(isShow: $showNewTask, name: "", priority: .normal)
                }
            }
            .navigationTitle("ToDo List")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        self.showNewTask = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.purple)
                    }
                }
            }
        }
    }
    
    private func deleteTask(at indexSet: IndexSet) {
        for index in indexSet {
            let itemToDelete = todoItems[index]
            modelContext.delete(itemToDelete)
        }
        
        do {
            try modelContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}

@MainActor
let previewContainer: ModelContainer = {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ToDoItem.self, configurations: config)
        for index in 0..<10 {
            let newItem = ToDoItem(name: "To do item #\(index)")
            container.mainContext.insert(newItem)
        }
        return container
    } catch {
        fatalError("Failed to create container")
    }
}()


#Preview {
    ContentView()
        .modelContainer(previewContainer)
}

#Preview("No Data") {
    ContentView()
}

struct BlankView : View {

    var bgColor: Color

    var body: some View {
        VStack {
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(bgColor)
        .edgesIgnoringSafeArea(.all)
    }
}

struct NoDataView: View {
    var body: some View {
        Image("welcome")
            .resizable()
            .scaledToFit()
    }
}

struct ToDoListRow: View {
    
    @Environment(\.modelContext) private var modelContext
    @Bindable var todoItem: ToDoItem
    
    var body: some View {
        Toggle(isOn: self.$todoItem.isComplete) {
            HStack {
                Text(self.todoItem.name)
                    .strikethrough(self.todoItem.isComplete, color: .black)
                    .animation(.default)
                
                Spacer()
                
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundColor(self.color(for: self.todoItem.priority))
            }
        }
        .toggleStyle(CheckboxStyle())
        .onChange(of: todoItem.isComplete) { _, _ in
            try? modelContext.save()
        }
    }
    
    private func color(for priority: Priority) -> Color {
        switch priority {
        case .high: return .red
        case .normal: return .orange
        case .low: return .green
        }
    }
}
