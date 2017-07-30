//
//  ShareViaEmailActivity.swift
//  GoGo Lists
//
//  Created by Victoria Corrodi on 7/29/17.
//  Copyright © 2017 Olivia Corrodi. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseAuthUI
import Firebase


class ShareViaEmailActivity: UIActivity {
    var customActivityType: UIActivityType
    var activityName: String
    var activityImageName: String
    var currentListUID: String
    var emailsAndUIDs: [String : String]
    var VC: IndividualListTableViewController

    
    
    // MARK: Initializer
    
    init(title: String, imageName: String, currentListUID: String, emailsAndUIDs: [String : String], VC: IndividualListTableViewController) {
        self.activityName = title
        self.activityImageName = imageName
        self.customActivityType = UIActivityType(rawValue: "Action \(title)")
        self.currentListUID = currentListUID
        self.emailsAndUIDs = emailsAndUIDs
        self.VC = VC
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
        return UIImage(named: activityImageName)
    }
    
    
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    
    
    override func prepare(withActivityItems activityItems: [Any]) {
        // Nothing to prepare
    }
    
    
    
    override func perform() {
        let user = Auth.auth().currentUser
        let alertController = UIAlertController(title: "Share List by Email", message: "Please enter an email to share this list with.", preferredStyle: .alert)
        let sendAction = UIAlertAction(title: "Send", style: .default, handler: { [unowned self] (UIAlertAction) in
            let sharingTextField = alertController.textFields?[0] as! UITextField
            let emailToShareWith = sharingTextField.text as! String
            
            let ref = Database.database().reference().child("users").child(user!.uid).child("lists").child(self.currentListUID)
            let uidToShareWith = self.emailsAndUIDs[emailToShareWith]
            ref.observeSingleEvent(of: .value, with: { [unowned self] snapshot in
                if let valueList = snapshot.value as? NSDictionary as? [String: Any] {
                    let ref2 = Database.database().reference().child("users").child(uidToShareWith!).child("lists").child(self.currentListUID)
                        // let childValues: [String: [String : [String : Any]]] = [uidToShareWith!: ["lists" : [(self.currentList?.uid)!: valueList]]]
                        //                    ref2.updateChildValues(childValues)
                    ref2.setValue(valueList)
                    
                }
            })
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (UIAlertAction) in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(sendAction)
        alertController.addTextField { (textField: UITextField) -> Void in
        self.VC.present(alertController, animated: true)
        }
    }
    
}
