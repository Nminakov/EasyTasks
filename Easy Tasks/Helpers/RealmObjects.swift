//
//  RealmObjects.swift
//  Homework Tasks
//
//  Created by Nikita on 17.10.2020.
//

import Foundation
import RealmSwift

class RealmObjects {
    static func objects<T: Object>(type: T.Type) -> Results<T>? {
        let realm = try? Realm()
        return realm?.objects(type)
    }
}
