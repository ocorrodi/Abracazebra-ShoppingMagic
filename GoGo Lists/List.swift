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
    
    init(title: String, items: [Item]) {
        self.title = title
        self.items = items
    }
}
