//
//  SwiftUIToDoListApp.swift
//  SwiftUIToDoList
//
//  Created by Simon Ng on 28/7/2023.
//

import SwiftUI

@main
struct SwiftUIToDoListApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: ToDoItem.self)
    }
}
