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
    
    var listSelectedTitle: String = ""
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    var lists = [List]()
    var newList = List(title: "", items: [])
    var editedList = List(title: "", items: [])
    var indexPath2: Int = 0
    let user = Auth.auth().currentUser

    @IBOutlet weak var listTitleLabel: UILabel!
    
    
    override func viewDidLoad() {
 //       UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "Chalkboard SE", size: 25)!]
//        self.navigationController?.navigationBar.tintColor = UIColor .white
        
        super.viewDidLoad()
        getLists { (retrievedLists) in
            self.lists = retrievedLists
            self.tableView.reloadData()
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()


    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getLists(completion: { (retrievedLists) in
            self.lists = retrievedLists
            self.tableView.reloadData()
        })
        self.activityView.isHidden = true
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showList" {
            let destinationVC3 = segue.destination as! IndividualListTableViewController
            print(listSelectedTitle)
            destinationVC3.listTitle = listSelectedTitle
//            destinationVC3.listIndex = lists.index(of: listSelectedTitle)!
        }
    }
    
    @IBAction func newListButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Add List", message: "please enter a name for the new list", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "save", style: .default, handler: {
            alert -> Void in
            let newListTextField = alertController.textFields![0] as UITextField
            
            if let newList = newListTextField.text {
                let ref = Database.database().reference().child("users").child(self.user!.uid).child("lists")
                ref.updateChildValues([newList : ["press + to add items, swipe left to delete" : ["price" : "price", "barcode" : "barcode", "brand" : "brand", "imageURL" : "imageURL", "buyingOptions" : [[" "]], "favorite" : false]]])
                self.getLists(completion: { (retrievedLists) in
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
    
    func getLists(completion: @escaping ([List]) -> Void) {
        self.activityView.isHidden = false
        self.activityView.startAnimating()
        let user = Auth.auth().currentUser
        let ref = Database.database().reference().child("users").child(user!.uid).child("lists")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let valueDictionary = snapshot.value as? NSDictionary as? [String: [String : Any]] {
                var listsToPass = [List]()
                
                for child in valueDictionary.keys {
                    let list = List(title: child, items: [])
//                    for item in valueDictionary[child]!.keys {
//                        let item = Item(title: item, brand: valueDictionary[child]![item]!["brand"]!, price: valueDictionary[child]![item]!["price"]!, barcode: valueDictionary[child]![item]!["barcode"]!, imageURL: valueDictionary[child]![item]!["imageURL"]!, buyingOptions: [[]])
//                        list.items.append(item)
//                    }

                    listsToPass.append(list)
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
        if editingStyle == .delete {
            let user = Auth.auth().currentUser
            let index = indexPath[1]
            print(index)
            print(lists)
            let listToBeDeleted = lists[index]
            print(listToBeDeleted.title)
            let ref = Database.database().reference().child("users").child((user?.uid)!).child("lists").child(listToBeDeleted.title)
            lists.remove(at: index)
            tableView.reloadData()
            ref.setValue(nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        indexPath2 = indexPath.row
        let listEdited = self.lists[self.indexPath2]
        if listEdited.title != "favorites and recents" {
            let alertController = UIAlertController(title: "Edit List", message: "please enter the new name for the list", preferredStyle: .alert)
            let saveAction = UIAlertAction(title: "save", style: .default, handler: {
                alert -> Void in
                let newListTextField = alertController.textFields![0] as UITextField
            
                if let newList = newListTextField.text {
                    let ref = Database.database().reference().child("users").child(self.user!.uid).child("lists").child(listEdited.title)
                    ref.observeSingleEvent(of: .value, with: { snapshot in
                        if let valueDictionary = snapshot.value as? NSDictionary as? [String: [String: Any]] {
                            print(valueDictionary)
                            ref.setValue(nil)
                            let ref2 = Database.database().reference().child("users").child(self.user!.uid).child("lists")
                            ref2.updateChildValues([newList : valueDictionary])
                            self.getLists(completion: { (retrievedLists) in
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
        listSelectedTitle = lists[indexPath.row].title
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showList", sender: nil)
    }
    
}

