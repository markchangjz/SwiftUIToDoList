//
//  ContentView.swift
//  SwiftUIToDoList
//
//  Created by Simon Ng on 28/7/2023.
//

import SwiftUI
import SwiftData

struct ContentView: View {
        
    @Query(sort: [SortDescriptor(\ToDoItem.priorityNum, order: .reverse), SortDescriptor(\ToDoItem.name, order: .forward)]) var todoItems: [ToDoItem] = []
    
    enum OverlayState {
        case hidden
        case adding
        case editing(ToDoItem)
    }
    
    @State private var overlayState: OverlayState = .hidden
    @State private var searchText = ""

    @Environment(\.modelContext) private var modelContext
    
    private var filteredTodoItems: [ToDoItem] {
        todoItems.filter {
            searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        
        NavigationStack {
            SearchBar(text: $searchText)
            ZStack {
                List {
                    ForEach(filteredTodoItems) { todoItem in
                        ToDoListRow(todoItem: todoItem)
                            .onTapGesture {
                                self.overlayState = .editing(todoItem)
                            }
                    }
                    .onDelete(perform: deleteTask)
                }
                .listStyle(.plain)
                .overlay {
                    if todoItems.isEmpty {
                        NoDataView()
                    }
                }
                
                // Overlay View Display
                switch overlayState {
                case .hidden:
                    EmptyView()
                case .adding:
                    BlankView(bgColor: .black)
                        .opacity(0.5)
                        .onTapGesture {
                            self.overlayState = .hidden
                        }
                    
                    NewToDoView(onDismiss: { overlayState = .hidden }, name: "", priority: .normal)
                case .editing(let item):
                    BlankView(bgColor: .black)
                        .opacity(0.5)
                        .onTapGesture {
                            self.overlayState = .hidden
                        }
                    
                    EditToDoView(toDoItem: item, onDismiss: { overlayState = .hidden })
                }
            }
            .navigationTitle("ToDo List")
//            .searchable(text: $searchText, prompt: "Search...") // 使用系統
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        self.overlayState = .adding
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
            let itemToDelete = filteredTodoItems[index]
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
            .contentShape(Rectangle())
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
