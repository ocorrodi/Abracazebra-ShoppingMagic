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
    var buyingOptions: [BuyingOption] = []
    var favorite: Bool = false
    
    init(title: String, brand: String, price: String, barcode: String, imageURL: String, buyingOptions: [BuyingOption], favorite: Bool) {
        self.title = title
        self.brand = brand
        self.price = price
        self.barcode = barcode
        self.imageURLString = imageURL
        self.buyingOptions = buyingOptions
        self.favorite = favorite
        
    }
    
    init?(json: JSON) {
        
        let barcode = self.barcode
       guard let title = json["items"][0]["title"].string,
        let imageURLString = json["items"][0]["images"][0].string
        else {
            return nil
        }
        if json["items"][0]["offers"].count != 0 {
            for x in 0...(json["items"][0]["offers"].count)-1 {
                let newBuyingOption = BuyingOption(name: json["items"][0]["offers"][x]["merchant"].string!, price: json["items"][0]["offers"][x]["price"].double!, link: json["items"][0]["offers"][x]["link"].string!)
                buyingOptions.append(newBuyingOption)
                
                //buyingOptions.append([json["items"][0]["offers"][x]["merchant"].string!, json["items"][0]["offers"][x]["link"].string!, "\(json["items"][0]["offers"][x]["price"].double!)"])
            }

        }
        
        if let thePrice = json["items"][0]["lowest_recorded_price"].double, String(thePrice) != "0.00"  {
            self.price = String(thePrice)
        }
        else{
            self.price = "not available"
        }
         

        var brand2 = ""
        if json["items"][0]["brand"].string != nil {
            brand2 = json["items"][0]["brand"].string!
            
        }
        else {
            brand2 = "not available"
        }

        

        
        self.title = title
        //self.brand = brand
        self.brand = brand2

        
//        if price <= 0 {
//            self.price = "not available"
//        }
//        self.price = String(format: "%.2f", price)
        self.barcode = barcode
        self.imageURLString = imageURLString
        self.favorite = false
        
    }

    
}
