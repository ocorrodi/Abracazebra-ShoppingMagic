//
//  APIManager.swift
//  GoGo Lists
//
//  Created by Victoria Corrodi on 7/19/17.
//  Copyright © 2017 Olivia Corrodi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class APIManager {
    static func getInfoForItem(withBarcode barcode: String, completionHandler: @escaping (String?, Item?) -> Void) {
        
        let apiToContact = "https://api.upcitemdb.com/prod/trial/lookup?upc=\(barcode)"
        var errorMessage = ""
        
        Alamofire.request(apiToContact).validate().responseJSON() { response in
            switch response.result {
                
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    if let item = Item(json: json) {
                        completionHandler(nil, item)
                    }
                    
//                    if item != nil {
//                        completionHandler(nil, item)
                    else  {
                        errorMessage = "Failed to initialize item with json."
                        completionHandler(errorMessage, nil)
                    }
                    
                }
            case .failure(let error):
                print(error)
                errorMessage = error.localizedDescription
                completionHandler(errorMessage, nil)
            }
        }
    }
    
}
