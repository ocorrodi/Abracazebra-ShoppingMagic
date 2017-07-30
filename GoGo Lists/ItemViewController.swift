//
//  ItemViewController.swift
//  GoGo Lists
//
//  Created by Victoria Corrodi on 7/14/17.
//  Copyright © 2017 Olivia Corrodi. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseAuthUI
import Alamofire
import SwiftyJSON
import AlamofireImage
import Kingfisher


class ItemViewController: UIViewController {
    
    @IBOutlet weak var titeTextField: UITextField!
    
    @IBOutlet weak var brandTextField: UITextField!
    
    @IBOutlet weak var priceTextField: UITextField!
    
    @IBOutlet weak var barcodeTextField: UITextField!
    
    @IBOutlet weak var itemImageView: UIImageView!
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBOutlet weak var buyingOptionsButton: UIButton!
    
    
    var item: Item = Item(title: "", brand: "", price: "", barcode: "", imageURL: " ", buyingOptions: [], favorite: false)
    var listTitle: List?
    var itemIndex = 0
    var barcodeScanned = ""
    var oldItemTitle = ""
    var buyingOptions: [[String]] = [[]]
    var editingTheItem = false
    var isAPublicItem = false
    var favorite = false

    
    
    @IBAction func showBuyingOptionsButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "showBuyingOptions", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "Chalkboard SE", size: 25)!, NSForegroundColorAttributeName: UIColor.white]

        if item.imageURLString != " " {
            self.itemImageView.downloadedFrom(url: URL(string: item.imageURLString)!)
        }
        self.tabBarController?.tabBar.isHidden = true
        print(item)
        if editingTheItem {
            oldItemTitle = item.title
            favorite = item.favorite
        }
        if barcodeScanned != "" {
//            apiCall()
            
            //ApiManager.getInfoForItem(withBarcode: barcodeScanned)
            
            

            APIManager.getInfoForItem(withBarcode: barcodeScanned) { (errorMessage, item) in
                
                if errorMessage == nil {
                    self.item = item!
                    if item?.title == "" {
                        self.showErrorAlert(message: "Item not found")
                    }
                    print(item?.buyingOptions)
                    self.titeTextField.text = item?.title
                    self.brandTextField.text = item?.brand
                    self.priceTextField.text = item?.price
                    self.barcodeTextField.text = self.barcodeScanned
                    item?.favorite = false
                    if item?.imageURLString != "" {
                        self.itemImageView.downloadedFrom(url: URL(string: item!.imageURLString)!)
                    }
                } else {
                    self.showErrorAlert(message: errorMessage!)
                }
                
            }
            
            
//            barcodeTextField.text = barcodeScanned
//            titeTextField.text = "scanneditem"
        }
        
        if item.title != "" {
            titeTextField.text = item.title
            brandTextField.text = item.brand
            priceTextField.text = item.price
            barcodeTextField.text = item.barcode
            
        }
        if item.favorite == true {
            favoriteButton.isEnabled = false
            favoriteButton.setTitle("Already a Favorite!", for: .normal)
        }
        else {
            favoriteButton.isEnabled = true
            favoriteButton.setTitle("☆ Add to Favorites ☆", for: .normal)
        }
        if item.buyingOptions.count == 0 {
            buyingOptionsButton.setTitle("No Buying Options", for: .normal)
            buyingOptionsButton.isEnabled = false
        }
        else {
            buyingOptionsButton.setTitle("View Buying Options", for: .normal)
            buyingOptionsButton.isEnabled = true
        }
    }
    
    func showErrorAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message:
            message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func doneAddingButtonPressed(_ sender: Any) {
        if priceTextField.text != "" {
            item.price = priceTextField.text!
        }
        else {
            item.price = "not entered"
        }
        
        
        if titeTextField.text != "" {
            item.title = titeTextField.text!
        }
        else {
            print("not filled in!")
            item.title = "not entered"
        }
        item.brand = brandTextField.text!
        if item.brand == "" {
            item.brand = "not entered"
        }
        item.barcode = barcodeTextField.text!
        if item.barcode == "" {
            item.barcode = "not entered"
        }
        let user = Auth.auth().currentUser
        //let ref =Database.database().reference().child("users").child((user?.uid)!).child("lists").child(listTitle).chid("items").child(itemTitle)
        let databaseReference = Database.database().reference()
        
        item.title = (item.title as NSString).replacingOccurrences(of: ".", with: ",")
        print(item.title)
        print(listTitle)
        let ref = databaseReference.child("users").child(user!.uid).child("lists").child((listTitle?.uid)!).child(item.title)
        print(oldItemTitle)
        //deleting old item from private lists if it exists
        if oldItemTitle != "" {
            let deletingRef = databaseReference.child("users").child(user!.uid).child("lists").child((listTitle?.uid)!).child(oldItemTitle)
            deletingRef.removeValue()
                
        }
        var buyingOptionsList = [String : [String : Any]]()
        for (index, buyingOptionItem) in item.buyingOptions.enumerated() {
            let objectDict = buyingOptionItem.convertObjectToDictionary()
            buyingOptionsList[String(index)] = objectDict
            
        }

        

        
//        ref.updateChildValues(["0": "test"]) { (returnedError, returnedReference) in
//            if let temporaryReturnedError = returnedError
//            {
//                print(temporaryReturnedError.localizedDescription)
//            }
//            else
//            {
//                print("success")
//            }
//        }
//        
//        ref.observeSingleEvent(of: .value, with: { (returnedSnapshot) in
//            print(returnedSnapshot)
//        })
        
            //updating user's private lists with new/updated item
        
            ref.updateChildValues(["brand" : item.brand])
            ref.updateChildValues(["price" : item.price])
            ref.updateChildValues(["barcode" : item.barcode])
            ref.updateChildValues(["imageURL" : item.imageURLString])
            ref.updateChildValues(["buyingOptions" : buyingOptionsList])
            ref.updateChildValues(["favorite" : item.favorite])
            if favorite {
                ref.updateChildValues(["favorite" : true])
            }
            else {
                ref.updateChildValues(["favorite" : false])
                
            }
        
        //updating recents
            let ref2 = Database.database().reference().child("users").child(user!.uid).child("lists").child("favorites and recents").child(item.title)
            ref2.updateChildValues(["brand" : item.brand])
            ref2.updateChildValues(["price" : item.price])
            ref2.updateChildValues(["barcode" : item.barcode])
            ref2.updateChildValues(["buyingOptions" : buyingOptionsList])
            ref2.updateChildValues(["imageURL" : item.imageURLString])
            if favorite {
                ref2.updateChildValues(["favorite" : true])
            }
            else {
                ref2.updateChildValues(["favorite" : false])
            }
            let ref3 = Database.database().reference().child((user?.uid)!).child("lists").child((listTitle?.uid)!)
            ref3.observeSingleEvent(of: .value, with: { snapshot in
                if let valueDict = snapshot.value as? NSDictionary as? [String : Any] {
                    if valueDict["isPublic"] as! Bool == true {
                        let ref4 = databaseReference.child("public lists").child((self.listTitle?.uid)!).child(self.item.title)
                        if self.oldItemTitle != "" {
                            ref4.removeValue()
                        }
                        ref4.updateChildValues(["brand" : self.item.brand])
                        ref4.updateChildValues(["price" : self.item.price])
                        ref4.updateChildValues(["barcode" : self.item.barcode])
                        ref4.updateChildValues(["imageURL" : self.item.imageURLString])
                        ref4.updateChildValues(["buyingOptions" : buyingOptionsList])
                        ref4.updateChildValues(["favorite" : false])
                    }
                
                }
                
            })
        
        //updating public reference with item if list is public
        if isAPublicItem {
            let publicRef = Database.database().reference().child("public lists").child((listTitle?.uid)!).child(item.title)
            publicRef.removeValue()
            publicRef.updateChildValues(["brand" : item.brand])
            publicRef.updateChildValues(["price" : item.price])
            publicRef.updateChildValues(["barcode" : item.barcode])
            publicRef.updateChildValues(["imageURL" : item.imageURLString])
            publicRef.updateChildValues(["buyingOptions" : item.buyingOptions])
            publicRef.updateChildValues(["favorite" : false])

        }
        
        performSegue(withIdentifier: "unwindToList", sender: self)
    }
    
    
    func apiCall() {
        let apiToContact = "https://api.upcitemdb.com/prod/trial/lookup?upc=\(barcodeScanned)"
        Alamofire.request(apiToContact).validate().responseJSON() { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    let title = json["items"][0]["title"]
                    var price = json["items"][0]["lowest_recorded_price"]
                    let brand = json["items"][0]["brand"]
                    let imageURL = json["items"][0]["images"][0]

                    
                    let imageURLString = "\(imageURL)"
                    print(imageURLString)
                    
                    
                    self.loadImage(imageURLString: imageURLString)
                    if price <= 0 {
                        price = "not available"
                    }
                    self.item.price = "\(price)"
                    self.item.brand = "\(title)"
                    self.item.brand = "\(brand)"
                    self.item.title = "\(title)"
                    print("\(title)")
                    

                    
                    // Do what you need to with JSON here!
                    // The rest is all boiler plate code you'll use for API requests
                    
                    
                }
            case .failure(let error):
                print(error)
                let alertController = UIAlertController(title: "Something went wrong", message:
                    "Item not found", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    
    func loadImage(imageURLString: String){
        print(imageURLString)
        let url = URL(string: imageURLString)
        let resource = ImageResource(downloadURL: url!)
        itemImageView.kf.setImage(with: resource)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBuyingOptions" {
            let destinationVC = segue.destination as! BuyingOptionsTableViewController
            destinationVC.item = item
        }
    }

    @IBAction func addToFavoritesButtonPressed(_ sender: Any) {
        if priceTextField.text != "" {
            item.price = priceTextField.text!
        }
        else {
            item.price = " "
        }
        
        
        if titeTextField.text != "" {
            item.title = titeTextField.text!
        }
        else {
            print("not filled in!")
            item.title = " "
        }
        item.brand = brandTextField.text!
        if item.brand == "" {
            item.brand = " "
        }
        item.barcode = barcodeTextField.text!
        if item.barcode == "" {
            item.barcode = " "
        }
        let user = Auth.auth().currentUser
        let listIndex = "\(itemIndex)"
        //let ref = Database.database().reference().child("users").child((user?.uid)!).child("lists").child(listTitle).child("items").child(itemTitle)
        let databaseReference = Database.database().reference()
        
        item.title = (item.title as NSString).replacingOccurrences(of: ".", with: ",")
        print(item.title)
        print(listTitle)
        let ref = databaseReference.child("users").child(user!.uid).child("lists").child((listTitle?.uid)!).child(item.title)
        print(oldItemTitle)
        if oldItemTitle != "" {
            let deletingRef = databaseReference.child("users").child(user!.uid).child("lists").child((listTitle?.uid)!).child(oldItemTitle)
            deletingRef.removeValue()
            
        }

        item.favorite = true
        print(item.title)
        let ref3 = Database.database().reference().child("users").child(user!.uid).child("lists").child("favorites and recents")
        let ref2 = Database.database().reference().child("users").child(user!.uid).child("lists").child("favorites and recents").child(item.title)
        var buyingOptionsList = [String : [String : Any]]()
        for (index, buyingOptionItem) in item.buyingOptions.enumerated() {
            let objectDict = buyingOptionItem.convertObjectToDictionary()
            buyingOptionsList[String(index)] = objectDict
            
        }
        ref2.updateChildValues(["brand" : item.brand])
        ref2.updateChildValues(["price" : item.price])
        ref2.updateChildValues(["barcode" : item.barcode])
        ref2.updateChildValues(["buyingOptions" : buyingOptionsList])
        ref2.updateChildValues(["favorite" : item.favorite])
        ref2.updateChildValues(["imageURL" : item.imageURLString])
        
        ref3.updateChildValues(["name" : "favorites and recents"])

        
        let alertController = UIAlertController(title: "Done!", message: "\(item.title) has been added to favorites!", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: { (UIAlertAction) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(dismissAction)
        self.present(alertController, animated: true, completion: nil)
        favoriteButton.isEnabled = false
    }
    

    @IBAction func userTappedBackground(sender: AnyObject) {
        view.endEditing(true)
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
