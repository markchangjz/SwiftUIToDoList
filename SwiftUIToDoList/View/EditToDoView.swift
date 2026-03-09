//
//  EditToDoView.swift
//  SwiftUIToDoList
//
//  Created by Mark Chang on 2026/3/9.
//

import SwiftUI

struct EditToDoView: View {
    
    var toDoItem: ToDoItem
    var onDismiss: () -> Void
    
    @State private var name: String = ""
    @State private var priority: Priority = .normal
    @State private var isEditing = false
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Edit task")
                        .font(.system(.title, design: .rounded))
                        .bold()
                    
                    Spacer()
                    
                    Button(action: {
                        self.onDismiss()
                        
                    }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(.black)
                            .font(.headline)
                    }
                }
                
                TextField("Enter the task description", text: $name, onEditingChanged: { (editingChanged) in
                    
                    self.isEditing = editingChanged
                    
                })
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.bottom)
                
                Text("Priority")
                    .font(.system(.subheadline, design: .rounded))
                    .padding(.bottom)
                
                HStack {
                    Text("High")
                        .font(.system(.headline, design: .rounded))
                        .padding(10)
                        .background(priority == .high ? Color.red : Color(.systemGray4))
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                        .onTapGesture {
                            priority = .high
                        }
                    
                    Text("Normal")
                        .font(.system(.headline, design: .rounded))
                        .padding(10)
                        .background(priority == .normal ? Color.orange : Color(.systemGray4))
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                        .onTapGesture {
                            priority = .normal
                        }
                    
                    Text("Low")
                        .font(.system(.headline, design: .rounded))
                        .padding(10)
                        .background(priority == .low ? Color.green : Color(.systemGray4))
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                        .onTapGesture {
                            priority = .low
                        }
                }
                .padding(.bottom, 30)
                
                // Save button for adding the todo item
                Button(action: {
                    
                    if name.trimmingCharacters(in: .whitespaces) == "" {
                        return
                    }
                    
                    self.onDismiss()
                    
                    // Only update the model data when "Save" is pressed.
                    toDoItem.name = name
                    toDoItem.priority = priority
                    
                    self.editTask()
                    
                }) {
                    Text("Save")
                        .font(.system(.headline, design: .rounded))
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(.white)
                        .background(.purple)
                        .cornerRadius(10)
                }
                .padding(.bottom)
                
            }
            .padding()
            .background(.white)
            .cornerRadius(10, antialiased: true)
            .offset(y: isEditing ? -320 : 0)
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            self.name = toDoItem.name
            self.priority = toDoItem.priority
        }
    }
    
    private func editTask() {
        do {
            try modelContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    EditToDoView(toDoItem: ToDoItem(name: "Buy a book", priority: .low), onDismiss: {})
}
