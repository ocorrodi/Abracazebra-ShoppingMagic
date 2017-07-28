//
//  ListsTableViewController.swift
//  
//
//  Created by Victoria Corrodi on 7/11/17.
//
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseAuthUI

class ListsTableViewController: UITableViewController {
    
    var selectedList: List?
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var addNewListButton: UIBarButtonItem!
    
    
    var lists = [List]()
    var newList = List(title: "", items: [], uid: "")
    var editedList = List(title: "", items: [], uid: "")
    var indexPath2: Int = 0
    let user = Auth.auth().currentUser
    var publicLists = false
    var privateLists = true


    @IBOutlet weak var listTitleLabel: UILabel!
    
    
    override func viewDidLoad() {
 //       UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "Chalkboard SE", size: 25)!]
//        self.navigationController?.navigationBar.tintColor = UIColor .white
        
        super.viewDidLoad()
        if publicLists {
            getPublicLists(completion: { (retrievedLists) in
                self.lists = retrievedLists
                self.tableView.reloadData()
            })
        }
        else {
            getPrivateLists(completion: { (retrievedLists) in
                self.lists = retrievedLists
                self.tableView.reloadData()
            })

        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()


    }
    
    override func viewWillAppear(_ animated: Bool) {
        if publicLists {
            getPublicLists(completion: { (retrievedLists) in
                self.lists = retrievedLists
                self.tableView.reloadData()
            })
        }
        else {
            getPrivateLists(completion: { (retrievedLists) in
                self.lists = retrievedLists
                self.tableView.reloadData()
            })
        }
        self.activityView.isHidden = true
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showList" {
            let destinationVC3 = segue.destination as! IndividualListTableViewController
            print(selectedList)
            destinationVC3.currentList = selectedList
            if publicLists {
                destinationVC3.isAPublicItem = true
            }
//            destinationVC3.listIndex = lists.index(of: listSelectedTitle)!
        }
    }
    
    @IBAction func newListButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Add List", message: "please enter a name for the new list", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "save", style: .default, handler: {
            alert -> Void in
            let newListTextField = alertController.textFields![0] as UITextField
            
            if let newList = newListTextField.text {
                let ref = Database.database().reference().child("users").child(self.user!.uid).child("lists").childByAutoId()
                let ref2 = Database.database().reference().child("users").child(self.user!.uid)
                ref2.updateChildValues(["email" : self.user?.email])
                
                ref.updateChildValues(["press + to add items, swipe left to delete" : ["price" : "price", "barcode" : "barcode", "brand" : "brand", "imageURL" : "imageURL", "buyingOptions" : ["lkj":["merchant":" bob", "price" : 0, "link" : " "]], "favorite" : false], "isPublic" : false, "name" : newList])
                self.getPrivateLists(completion: { (retrievedLists) in
                    self.lists = retrievedLists
                    self.tableView.reloadData()
                })

            }
        })
            
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: {
            alert -> Void in
            alertController.dismiss(animated: true, completion: nil)
            
            })

        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        alertController.addTextField { (textField: UITextField) -> Void in
        }
        self.present(alertController, animated: true, completion: nil)
        
        //self.performSegue(withIdentifier: "toAddList", sender: self)
    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Are you sure?", message: "Do you really want to logout?", preferredStyle: .alert)
        let continueAction = UIAlertAction(title: "Continue", style: .default, handler: {
            alert -> Void in
            self.performSegue(withIdentifier: "unwindSegueToIntro", sender: self)
            do {
                try Auth.auth().signOut()
            }
            catch let error as NSError {
                assertionFailure("Error signing out: \(error.localizedDescription)")
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { alert -> Void in
            alertController.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(cancelAction)
        alertController.addAction(continueAction)
        self.present(alertController, animated: true, completion: nil)
        
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
    
    func getPrivateLists(completion: @escaping ([List]) -> Void) {
        self.activityView.isHidden = false
        self.activityView.startAnimating()
        let user = Auth.auth().currentUser
        let ref = Database.database().reference().child("users").child(user!.uid).child("lists")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let valueDictionary = snapshot.value as? NSDictionary as? [String: Any] {
                var listsToPass = [List]()
                
                for (key, value) in valueDictionary{//child in valueDictionary.keys {
                    var dictionary = value as! [String : Any]
                    
                    if let title = dictionary["name"] as? String{
                        let list = List(title: title, items: [], uid: key)
                        
                        
                        //                    for item in valueDictionary[child]!.keys {
                        //                        let item = Item(title: item, brand: valueDictionary[child]![item]!["brand"]!, price: valueDictionary[child]![item]!["price"]!, barcode: valueDictionary[child]![item]!["barcode"]!, imageURL: valueDictionary[child]![item]!["imageURL"]!, buyingOptions: [[]])
                        //                        list.items.append(item)
                        //                    }
                        if key != "isPublic" {
                            
                            listsToPass.append(list)
                        }

                    }
                    else{
                        let title = "favorites and recents"
                        let list = List(title: title, items: [], uid: title)
                        if key != "isPublic" {
                            
                            listsToPass.append(list)
                        }
                    }
                }
                
                self.activityView.isHidden = true
                self.activityView.stopAnimating()
                
                return completion(listsToPass)
            } else {
                self.activityView.isHidden = true
                self.activityView.stopAnimating()
                completion([])
            }
        })
    }
    func getPublicLists(completion: @escaping ([List]) -> Void) {
        self.activityView.isHidden = false
        self.activityView.startAnimating()
        let user = Auth.auth().currentUser
        let ref = Database.database().reference().child("public lists")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let valueDictionary = snapshot.value as? NSDictionary as? [String: Any] {
                var listsToPass = [List]()
                
                for child in valueDictionary.keys {
                    let list = List(title: child, items: [], uid: child)
                    //                    for item in valueDictionary[child]!.keys {
                    //                        let item = Item(title: item, brand: valueDictionary[child]![item]!["brand"]!, price: valueDictionary[child]![item]!["price"]!, barcode: valueDictionary[child]![item]!["barcode"]!, imageURL: valueDictionary[child]![item]!["imageURL"]!, buyingOptions: [[]])
                    //                        list.items.append(item)
                    //                    }
                    if child != "isPublic" {
                        listsToPass.append(list)
                    }
                }
                
                self.activityView.isHidden = true
                self.activityView.stopAnimating()
                
                return completion(listsToPass)
            } else {
                self.activityView.isHidden = true
                self.activityView.stopAnimating()
                completion([])
            }
        })
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if lists != nil {
            return lists.count
            
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! ListTableViewCell
        print(lists)
        let oneList = lists[indexPath.row]
        cell.listTitleLabel.text = oneList.title
        return cell
    }
    @IBAction func unwindToLists(segue:UIStoryboardSegue) {
    
    }
    
    @IBAction func unwindToLists2(segue: UIStoryboardSegue) {
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // 2
        if editingStyle == .delete, publicLists == false {
            let user = Auth.auth().currentUser
            let index = indexPath[1]
            print(index)
            print(lists)
            let listToBeDeleted = lists[index]
            print(listToBeDeleted.uid)
            let ref = Database.database().reference().child("users").child((user?.uid)!).child("lists").child(listToBeDeleted.uid)
            lists.remove(at: index)
            tableView.reloadData()
            ref.setValue(nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        indexPath2 = indexPath.row
        let listEdited = self.lists[self.indexPath2]
        if listEdited.title != "favorites and recents", privateLists == true {
            let alertController = UIAlertController(title: "Edit List", message: "please enter the new name for the list", preferredStyle: .alert)
            
            let saveAction = UIAlertAction(title: "save", style: .default, handler: {
                alert -> Void in
                let newListTextField = alertController.textFields![0] as UITextField
            
                if let newList = newListTextField.text {
                    let ref = Database.database().reference().child("users").child(self.user!.uid).child("lists").child(listEdited.uid)
                    ref.observeSingleEvent(of: .value, with: { snapshot in
                        if let valueDictionary = snapshot.value as? NSDictionary as? [String: Any] {
                            print(valueDictionary)
                            ref.setValue(nil)
                            let ref2 = Database.database().reference().child("users").child(self.user!.uid).child("lists").child(listEdited.uid)
                            
                            for (key,value) in valueDictionary {
                                if key != "name" {
                                    ref2.updateChildValues([key : value])
                                } else {
                                    ref2.updateChildValues(["name" : newList])
                                }
                                
                            }
                            self.getPrivateLists(completion: { (retrievedLists) in
                                self.lists = retrievedLists
                                self.tableView.reloadData()
                            })
                        }
                    })
                    
                }
            })
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: {
            alert -> Void in
            alertController.dismiss(animated: true, completion: nil)
        
            
        })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        alertController.addTextField { (textField: UITextField) -> Void in
            self.present(alertController, animated: true, completion: nil)
        }
    
    }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedList = lists[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showList", sender: nil)
    }
    
    
    @IBAction func segmentedControlChanged(_ sender: Any) {
        
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            print("private lists")
            getPrivateLists { (retrievedLists) in
                self.lists = retrievedLists
                self.tableView.reloadData()
            }
            addNewListButton.isEnabled = true
            privateLists = true
            publicLists = false

            
            ;
        case 1:
            print("public lists")
            getPublicLists { (retrievedLists) in
                self.lists = retrievedLists
                self.tableView.reloadData()
            }
            addNewListButton.isEnabled = false
            publicLists = true
            privateLists = false

            
            ;
        default:
            break; 
        }
    }
    
}

