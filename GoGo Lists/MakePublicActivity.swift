//
//  MakePublicActivity.swift
//  GoGo Lists
//
//  Created by Victoria Corrodi on 7/29/17.
//  Copyright © 2017 Olivia Corrodi. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseAuthUI
import Firebase


class zMakePublicActivity: UIActivity {
    
    var customActivityType: UIActivityType
    var activityName: String
    var activityImageName: String
    var currentListUID: String
    var emailsAndUIDs: [String : String]
    var VC: IndividualListTableViewController
    var currentListTitle: String
    var items: [Item]
    
    
    
    // MARK: Initializer
    
    init(title: String, imageName: String, currentListUID: String, emailsAndUIDs: [String : String], VC: IndividualListTableViewController, currentListTitle: String, items: [Item]) {
        self.activityName = title
        self.activityImageName = imageName
        self.customActivityType = UIActivityType(rawValue: "Action \(title)")
        self.currentListUID = currentListUID
        self.emailsAndUIDs = emailsAndUIDs
        self.VC = VC
        self.currentListTitle = currentListTitle
        self.items = items
        super.init()
    }
    
    
    
    // MARK: Overrides
    
    override var activityType: UIActivityType? {
        return customActivityType
    }
    
    
    
    override var activityTitle: String? {
        return activityName
    }
    
    
    
    override class var activityCategory: UIActivityCategory {
        return .share
    }
    
    
    
    override var activityImage: UIImage? {
        return UIImage(named: "unlock.jpg")
    }
    
    
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    
    
    override func prepare(withActivityItems activityItems: [Any]) {
        // Nothing to prepare
    }
    
    
    
    override func perform() {
        let alertController = UIAlertController(title: "Make List Public?", message: "Would you like to make this list public? This cannot be undone", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) in
            let user = Auth.auth().currentUser
            let ref = Database.database().reference().child("public lists")
            ref.updateChildValues([(self.currentListTitle) : ["dummy item name" : ["price" : " ", "barcode" : " ", "imageURL" : " ", "brand" : " ", "favorite" : false]]])
            let ref2 = ref.child(self.currentListTitle)
            let ref3 = ref.child(self.currentListTitle).child("isPublic")
            ref3.setValue(true)
            for item in self.items {
                ref2.updateChildValues([item.title : ["price" : item.price, "barcode" : item.barcode, "imageURL" : item.imageURLString, "brand" : item.brand, "favorite" : false]])
            }
            
        })
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: { (UIAlertAction) in
            alertController.dismiss(animated: true, completion: nil)
            
        })
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        self.VC.present(alertController, animated: true, completion: nil)
    }
}
