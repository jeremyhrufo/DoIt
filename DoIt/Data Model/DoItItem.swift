//
//  ToDoItem.swift
//  DoIt
//
//  Created by Jeremy Rufo on 8/7/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

struct DoItItem: Codable {
    var title: String = K.emptyString
    var isDone: Bool = false
    
    init(_ title: String) {
        self.title = title
    }
}
