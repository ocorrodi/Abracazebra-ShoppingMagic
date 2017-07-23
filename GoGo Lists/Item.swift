//
//  Item.swift
//  GoGo Lists
//
//  Created by Victoria Corrodi on 7/14/17.
//  Copyright © 2017 Olivia Corrodi. All rights reserved.
//

import Foundation
import SwiftyJSON

class Item {
    
    var title: String = ""
    var brand: String = ""
    var price: String = ""
    var barcode: String = ""
    var imageURLString: String = ""
    var buyingOptions: [[String]] = [[]]
    var favorite: Bool = false
    
    init(title: String, brand: String, price: String, barcode: String, imageURL: String, buyingOptions: [[String]], favorite: Bool) {
        self.title = title
        self.brand = brand
        self.price = price
        self.barcode = barcode
        self.imageURLString = imageURL
        self.buyingOptions = buyingOptions
        self.favorite = favorite
        
    }
    
    init?(json: JSON) {
        
        var buyingOptions: [[String]] = []
        
       guard let title = json["items"][0]["title"].string,
            let barcode = json["items"][0]["upc"].string,
            let price = json["items"][0]["lowest_recorded_price"].double,
            let brand = json["items"][0]["brand"].string,
        let imageURLString = json["items"][0]["images"][0].string
        else {
            return
        }
        if json["items"][0]["offers"].count != 0 {
            for x in 0...(json["items"][0]["offers"].count)-1 {
                buyingOptions.append([json["items"][0]["offers"][x]["merchant"].string!, json["items"][0]["offers"][x]["link"].string!, "\(json["items"][0]["offers"][x]["price"].double!)"])
            }
        }
        

        
        self.title = title
        self.brand = brand
        
        if price <= 0 {
            self.price = "not available"
        }
        else {
            self.price = String(format: "%.2f", price)
        }
        self.barcode = barcode
        self.imageURLString = imageURLString
        self.buyingOptions = buyingOptions
        self.favorite = false
        
    }

    
}
