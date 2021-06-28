//
//  Task.swift
//  Homework Tasks
//
//  Created by Nikita on 17.10.2020.
//

import Foundation
import RealmSwift

class Task: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var deadline: Date = Date()
    @objc dynamic var notificationTime: String = ""
    @objc dynamic var isRemind: Bool = false
    @objc dynamic var isFinished: Bool = false
    
    override class func primaryKey() -> String? {
        return "id"
    }
    

    
}

struct TaskModel {
    var id: String = UUID().uuidString
    var name: String
    var deadline: Date
    var notificationTime: String
    var isRemind: Bool
    var isFinished: Bool = false
}
