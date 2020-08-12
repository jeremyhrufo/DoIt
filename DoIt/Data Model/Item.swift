//
//  Item.swift
//  DoIt
//
//  Created by Jeremy Rufo on 8/10/20.
//  Copyright © 2020 JRufo, LLC. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class Item: Object {
    dynamic var title: String = K.emptyString
    dynamic var isDone: Bool = false
    dynamic var dateCreated: Date?

    // inverse relationship
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")

    init (with title: String) {
        self.title = title
        self.dateCreated = Date()
    }

    required convenience init () {
        self.init(with: K.emptyString)
    }
}
