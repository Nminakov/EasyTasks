//
//  Realm+Extensions.swift
//  Homework Tasks
//
//  Created by Nikita on 17.10.2020.
//

import Foundation
import RealmSwift

extension Object {
    
    /// Добавление объекта в БД
    func add() {
        let realm = try? Realm()
        try! realm?.write {
            realm?.add(self)
        }
    }
    /// Добавление объекта в БД с уникальным ключом
    func addWithPrimaryKey() {
        let realm = try? Realm()
        try! realm?.write {
            realm?.add(self, update: .all)
        }
    }
    
    /// Обновление объекта в БД
    /// - Parameter updateBlock: вынос обновления наружу
    func update(updateBlock: () -> ()) {
        let realm = try? Realm()
        try! realm?.write(updateBlock)
    }
    
    /// Удаление объекта из БД
    func delete() {
        let realm = try? Realm()
        try! realm?.write {
            realm?.delete(self)
        }
    }
}
