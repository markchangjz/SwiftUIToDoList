//
//  ToDoItem.swift
//  SwiftUIToDoList
//
//  Created by Simon Ng on 28/7/2023.
//

import SwiftUI
import SwiftData

enum Priority: Int {
    case low = 0
    case normal = 1
    case high = 2
}

@Model
class ToDoItem: Identifiable {
    var id: UUID
    var name: String
    
    @Transient var priority: Priority {
        get {
            return Priority(rawValue: Int(priorityNum)) ?? .normal
        }
        set {
            self.priorityNum = Int(newValue.rawValue)
        }
    }
    
    /*
     資料庫欄位會建立 priorityNum 這個欄位
     originalName: "priority" 的 "priority" 指的是資料庫裡的舊欄位名稱，它跟上方的 @Transient var priority 完全無關。
     originalName 參數，用於資料庫結構改版 (Schema Migration) 用
     */
    @Attribute(originalName: "priority") var priorityNum: Priority.RawValue
    
    var isComplete: Bool
    
    init(id: UUID = UUID(), name: String = "", priority: Priority = .normal, isComplete: Bool = false) {
        self.id = id
        self.name = name
        self.priorityNum = priority.rawValue
        self.isComplete = isComplete
    }
}

