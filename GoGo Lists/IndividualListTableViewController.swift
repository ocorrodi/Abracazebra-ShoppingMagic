//
//  IndividualListTableViewController.swift
//  GoGo Lists
//
//  Created by Victoria Corrodi on 7/13/17.
//  Copyright © 2017 Olivia Corrodi. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseAuthUI
import Firebase
import MessageUI
import AddressBookUI

class IndividualListTableViewController: UITableViewController, MFMessageComposeViewControllerDelegate {
    
    @IBOutlet weak var navigationControllerTitle: UINavigationItem!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    var currentList: List?
    var listIndex: Int = 0
    var items: [Item] = []
    var itemSelected: Item = Item(title: "", brand: "", price: "", barcode: "", imageURL: " ", buyingOptions: [], favorite: false)
    var isAPublicItem = false
    
    override func viewWillAppear(_ animated: Bool) {
        getEmailsAndUIDs { (emailsAndUID) in }
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "Chalkboard SE", size: 25)!]
        self.navigationController?.navigationBar.tintColor = UIColor .white

        self.activityView.isHidden = true
        let user = Auth.auth().currentUser
        if currentList?.title == "favorites and recents" {
            self.getPrivateItems { (retrievedItems) in
                self.items = retrievedItems
            }
            var recentItems = self.items.filter { $0.favorite != true }
            var favoriteItems = self.items.filter { $0.favorite }
            if recentItems.count > 10 {
                let ref = Database.database().reference().child("users").child(user!.uid).child("lists").child("favorites and recents").child(recentItems[10].title)
                ref.setValue(nil)
                recentItems.remove(at: 10)
            }
            tableView.reloadData()

        }
        if isAPublicItem {
            getPublicItems { (retrievedItems) in
                self.items = retrievedItems
                self.tableView.reloadData()
            }
        }
        else {
            getPrivateItems { (retrievedItems) in
                self.items = retrievedItems
                self.tableView.reloadData()
            }
        }

    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func makePublicButtonPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Make List Public?", message: "Would you like to make this list public? This cannot be undone", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) in
            let user = Auth.auth().currentUser
            let ref = Database.database().reference().child("public lists")
            ref.updateChildValues([(self.currentList?.title)! : ["dummy item name" : ["price" : " ", "barcode" : " ", "imageURL" : " ", "brand" : " ", "favorite" : false]]])
            let ref2 = ref.child((self.currentList?.title)!)
            let ref3 = ref.child((self.currentList?.title)!).child("isPublic")
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
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationControllerTitle.title = currentList?.title
        
    
        if isAPublicItem {
            getPublicItems { (retrievedItems) in
                self.items = retrievedItems
                self.tableView.reloadData()
            }
        }
        else {
            getPrivateItems { (retrievedItems) in
                self.items = retrievedItems
                self.tableView.reloadData()
            }
        }
//        navigationController?.navigationBar.backItem?.hidesBackButton = true
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addItem" {
            let destinationVC = segue.destination as! AddItemViewController
            destinationVC.listTitle = self.currentList!
            destinationVC.itemIndex = self.listIndex
            if isAPublicItem == true {
                destinationVC.isAPublicItem = true
            }
        }
        if segue.identifier == "showItem" {
            let destinationVC = segue.destination as! ItemViewController
            print(itemSelected)
            destinationVC.item = itemSelected
            destinationVC.listTitle = currentList
            destinationVC.editingTheItem = true
            if isAPublicItem == true{
                destinationVC.isAPublicItem = true
            }
            
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemTableViewCell
        let oneList = items[indexPath.row]
        cell.itemTitleLabel.text = oneList.title
        return cell
    }
    
    func getPublicItems(completion: @escaping ([Item]) -> Void) {
        self.activityView.isHidden = false
        self.activityView.startAnimating()
        let user = Auth.auth().currentUser
        let ref = Database.database().reference().child("public lists").child((currentList?.title)!)
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let valueList = snapshot.value as? NSDictionary as? [String: Any] {
                var itemsToPass = [Item]()
                for (key, value) in valueList {
                    if let value = value as? [String : Any]{
                        var buyingOptionsArray = [BuyingOption]()
                        
                        if key != "isPublic" {
                            if let unwrappedValue = value["buyingOptions"], let buyingOptions2 = unwrappedValue as? [String : Any]{
                                for (key,aBuyingOptionDict) in buyingOptions2{
                                    var castedDict = aBuyingOptionDict as! [String : Any]
                                    let buyingOptionObject = BuyingOption(dictionary: castedDict)
                                    buyingOptionsArray.append(buyingOptionObject)
                                }
                            }
                            else{
                                buyingOptionsArray = []
                            }
                            
                            
                            print(value["favorite"] as! Bool)
                            itemsToPass.append(Item(title: key, brand: value["brand"]! as! String, price: value["price"]! as! String, barcode: value["barcode"]! as! String, imageURL: value["imageURL"]! as! String, buyingOptions: buyingOptionsArray, favorite: value["favorite"] as! Bool))
                        }
                    }
                    
                }
                print(itemsToPass)
                self.activityView.isHidden = true
                self.activityView.stopAnimating()
                return completion(itemsToPass)
            } else {
                self.activityView.isHidden = true
                self.activityView.stopAnimating()
                return completion([])
            }
        })

    }

    
    func getPrivateItems(completion: @escaping ([Item]) -> Void) {
        self.activityView.isHidden = false
        self.activityView.startAnimating()
        let user = Auth.auth().currentUser
        let ref = Database.database().reference().child("users").child(user!.uid).child("lists").child((currentList?.uid)!)
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let valueList = snapshot.value as? NSDictionary as? [String: Any] {
                var itemsToPass = [Item]()
                for (key, value) in valueList {
                    if let value = value as? [String : Any]{
                        var buyingOptionsArray = [BuyingOption]()

                        if key != "isPublic" && key != "name"{
                            if let unwrappedValue = value["buyingOptions"], let buyingOptions2 = unwrappedValue as? [String : Any]{
                                for (key,aBuyingOptionDict) in buyingOptions2{
                                    var castedDict = aBuyingOptionDict as! [String : Any]
                                    let buyingOptionObject = BuyingOption(dictionary: castedDict)
                                    buyingOptionsArray.append(buyingOptionObject)
                                }
                            }
                            else{
                                buyingOptionsArray = []
                            }
                            
                            
                            print(value["favorite"] as! Bool)
                            itemsToPass.append(Item(title: key, brand: value["brand"]! as! String, price: value["price"]! as! String, barcode: value["barcode"]! as! String, imageURL: value["imageURL"]! as! String, buyingOptions: buyingOptionsArray, favorite: value["favorite"] as! Bool))
                        }
                    }
                    
 
                }
                print(itemsToPass)
                self.activityView.isHidden = true
                self.activityView.stopAnimating()
                return completion(itemsToPass)
            } else {
                self.activityView.isHidden = true
                self.activityView.stopAnimating()
                return completion([])
            }
        })

    }
    @IBAction func unwindToList(segue:UIStoryboardSegue) {
        getPrivateItems { (retrievedItems) in
            self.items = retrievedItems
            self.tableView.reloadData()
        }

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemSelected = items[indexPath.row]
        print(itemSelected.title)
        print(itemSelected.barcode)
        print(itemSelected.brand)
        print(itemSelected.price)
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showItem", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // 2
        if editingStyle == .delete, isAPublicItem == false {
            let user = Auth.auth().currentUser
            let index = indexPath[1]
            let itemToBeDeleted = items[index]
            print(itemToBeDeleted.title)
            let ref = Database.database().reference().child("users").child((user?.uid)!).child("lists").child((currentList?.uid)!).child(itemToBeDeleted.title)
            items.remove(at: index)
            tableView.reloadData()
            ref.setValue(nil)
        }
    }
    
    @IBAction func messageListButtonPressed(_ sender: Any) {
        
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        var itemsStr = ""
        for item in items {
            itemsStr += "\n" + item.title
        }
        composeVC.body = "items on \(currentList!.title): \(itemsStr)"
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func getEmailsAndUIDs(completion: @escaping ([String : String]) -> Void) {
        let user = Auth.auth().currentUser
        let ref = Database.database().reference().child("users")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let valueList = snapshot.value as? NSDictionary as? [String : [String : Any]] {
                var emailAndUIDDict: [String : String] = [:]
                for (key, value) in valueList.enumerated() {
                    let uid = "\(key)"
                    //let email = value["email"] as! String
                    //emailAndUIDDict[uid] = email
                    
                }
                return completion(emailAndUIDDict)
            }
            else { return completion([:]) }
            
        })
        
        
    }
    
    
    @IBAction func shareByUIDButtonPressed(_ sender: Any) {
        let user = Auth.auth().currentUser
        let alertController = UIAlertController(title: "Share List by UID", message: "Please enter a uid to share this list with. Your UID is : \(user!.uid)", preferredStyle: .alert)
            let sendAction = UIAlertAction(title: "Send", style: .default, handler: { [unowned self] (UIAlertAction) in
            let sharingTextField = alertController.textFields?[0] as! UITextField
            let uidToShareWith = sharingTextField.text

            let ref = Database.database().reference().child("users").child(user!.uid).child("lists").child((self.currentList?.uid)!)
            ref.observeSingleEvent(of: .value, with: { [unowned self] snapshot in
                if let valueList = snapshot.value as? NSDictionary as? [String: Any] {
                    let ref2 = Database.database().reference().child("users").child(uidToShareWith!).child("lists").child((self.currentList?.uid)!)
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
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
    
    
    




    

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

