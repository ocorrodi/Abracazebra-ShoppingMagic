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
    
    
    var item: Item = Item(title: "", brand: "", price: "", barcode: "", imageURL: " ", buyingOptions: [[" "]])
    var listTitle: String = " "
    var itemIndex = 0
    var barcodeScanned = ""
    var oldItemTitle = ""
    var buyingOptions: [[String]] = [[]]
    var editingTheItem = false
    
    
    @IBAction func showBuyingOptionsButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "showBuyingOptions", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if item.imageURLString != " " {
            self.itemImageView.downloadedFrom(url: URL(string: item.imageURLString)!)
        }
        print(item)
        if editingTheItem {
            oldItemTitle = item.title
        }
        if barcodeScanned != "" {
//            apiCall()
            
            //ApiManager.getInfoForItem(withBarcode: barcodeScanned)
            
            

            APIManager.getInfoForItem(withBarcode: barcodeScanned) { (errorMessage, item) in
                
                if errorMessage == nil {
                    self.item = item!
                    print(item?.buyingOptions)
                    self.titeTextField.text = item?.title
                    self.brandTextField.text = item?.title
                    self.priceTextField.text = item?.price
                    self.barcodeTextField.text = item?.barcode
                    self.itemImageView.downloadedFrom(url: URL(string: item!.imageURLString)!)
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
        
    }
    
    func showErrorAlert(message: String) {
        let alertController = UIAlertController(title: "Error.", message:
            message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
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
        let ref = databaseReference.child("users").child(user!.uid).child("lists").child(listTitle).child(item.title)
        print(oldItemTitle)
        if oldItemTitle != "" {
            let deletingRef = databaseReference.child("users").child(user!.uid).child("lists").child(listTitle).child(oldItemTitle)
            deletingRef.removeValue()
            
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
        
        ref.updateChildValues(["brand" : item.brand])
        ref.updateChildValues(["price" : item.price])
        ref.updateChildValues(["barcode" : item.barcode])
        ref.updateChildValues(["imageURL" : item.imageURLString])
        ref.updateChildValues(["buyingOptions" : item.buyingOptions])
        let ref2 = Database.database().reference().child("items").child(item.barcode)
        ref2.updateChildValues(["brand" : item.brand])
        ref2.updateChildValues(["price" : item.price])
        ref2.updateChildValues(["title" : item.title])
        ref2.updateChildValues(["buyingOptions" : item.buyingOptions])
    
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
                    if price == 0 {
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
                    "Please check your internet connection", preferredStyle: UIAlertControllerStyle.alert)
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
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}