//
//  BuyingOption.swift
//  GoGo Lists
//
//  Created by Victoria Corrodi on 7/26/17.
//  Copyright © 2017 Olivia Corrodi. All rights reserved.
//

import Foundation

class BuyingOption{
    var name : String?
    var price : Double?
    var link: String?
    
    init(dictionary : [String : Any]){
        self.name = dictionary["name"] as? String
        self.price = dictionary["price"] as? Double
        self.link = dictionary["link"] as? String
        
    }
    init(name: String, price: Double, link: String) {
        self.name = name
        self.price = price
        self.link = link
    }
    
    func convertObjectToDictionary()->[String : Any]{
        var dictionaryToGiveToServer : [String : Any] = [:]
        dictionaryToGiveToServer["name"] = self.name
        dictionaryToGiveToServer["price"] = self.price
        dictionaryToGiveToServer["link"] = self.link
        
        
        return dictionaryToGiveToServer
    }
    
}



