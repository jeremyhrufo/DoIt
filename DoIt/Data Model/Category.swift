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
    dynamic var colorHexString: String = K.defaultColor

    // Forward relationship
    let items = List<Item>()

    init (with name: String, and color: String = K.defaultColor) {
        self.name = name
        self.dateCreated = Date()
        self.colorHexString = color
    }

    required convenience init () {
        self.init(with: K.emptyString)
    }
}
