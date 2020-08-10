//
//  Category.swift
//  DoIt
//
//  Created by Jeremy Rufo on 8/10/20.
//  Copyright © 2020 JRufo, LLC. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class Category: Object {
    dynamic var name: String = K.emptyString
    dynamic var dateCreated: Date?

    // Forward relationship
    let items = List<Item>()

    init (with name: String) {
        self.name = name
        self.dateCreated = Date()
    }

    required convenience init () {
        self.init(with: K.emptyString)
    }
}
