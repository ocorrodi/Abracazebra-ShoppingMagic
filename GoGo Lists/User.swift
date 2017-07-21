//
//  User.swift
//  GoGo Lists
//
//  Created by Victoria Corrodi on 7/10/17.
//  Copyright © 2017 Olivia Corrodi. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

class User {
    
    let uid: String
    
    init(uid: String) {
        self.uid = uid
        
    }
    
    init?(snapshot: DataSnapshot) {
        
        guard let dict = snapshot.value as? [String : Any],
            let uid = dict["uid"] as? String
            else { return nil }
        
        self.uid = snapshot.key
    }
}
