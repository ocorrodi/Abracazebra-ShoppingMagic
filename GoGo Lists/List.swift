//
//  List.swift
//  GoGo Lists
//
//  Created by Victoria Corrodi on 7/17/17.
//  Copyright © 2017 Olivia Corrodi. All rights reserved.
//

import Foundation


class List {
    
    var title: String
    var items: [Item]
    var uid : String
    
    init(title: String, items: [Item], uid: String) {
        self.title = title
        self.items = items
        self.uid = uid
    }
}
