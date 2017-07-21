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
    
    var lists = [List]()
    var newList = List(title: "", items: [])
    var editedList = List(title: "", items: [])
    var indexPath2: Int = 0
    
    
    override func viewDidLoad() {
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
        print(newList.title)
        let user = Auth.auth().currentUser
        if newList.title != "" {
            let ref = Database.database().reference().child("users").child(user!.uid).child("lists")
            ref.updateChildValues([newList.title : ["this is a list, press the + button to add items" : ["price" : "price", "barcode" : "barcode", "brand" : "brand", "imageURL" : "imageURL", "buyingOptions" : [[" "]]]]])
            getLists(completion: { (retrievedLists) in
                self.lists = retrievedLists
                self.tableView.reloadData()
            })
            newList.title = ""
        }
        if editedList.title != "" {
            let listEdited = lists[indexPath2]
            print(listEdited.title)
            let ref = Database.database().reference().child("users").child(user!.uid).child("lists").child(listEdited.title)
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if let valueDictionary = snapshot.value as? NSDictionary as? [String: [String: String]] {
                    print(valueDictionary)
                    ref.setValue(nil)
                    let ref2 = Database.database().reference().child("users").child(user!.uid).child("lists")
                    ref2.updateChildValues([self.editedList.title : valueDictionary])
                    self.getLists(completion: { (retrievedLists) in
                        self.lists = retrievedLists
                        self.tableView.reloadData()
                    })
                    self.editedList.title = ""

                //["dummyItemName" : ["price" : "price", "barcode" : "barcode", "brand" : "brand"]]])

//            lists[indexPath2].title = editedList.title
//            lists.remove(at: indexPath2)
//            lists.append(editedList)
                }
            })
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toAddList" {
             let destinationVC2 = segue.destination as! AddListViewController
            destinationVC2.addList = true
        }
        if segue.identifier == "editList" {
             let destinationVC2 = segue.destination as! AddListViewController
            destinationVC2.editList = true
        }
        if segue.identifier == "showList" {
            let destinationVC3 = segue.destination as! IndividualListTableViewController
            print(listSelectedTitle)
            destinationVC3.listTitle = listSelectedTitle
//            destinationVC3.listIndex = lists.index(of: listSelectedTitle)!
        }
    }
    
    @IBAction func newListButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "toAddList", sender: self)
    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "unwindSegueToIntro", sender: self)
        do {
            try Auth.auth().signOut()
        }
        catch let error as NSError {
            assertionFailure("Error signing out: \(error.localizedDescription)")
        }
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
                
                return completion(listsToPass)
            } else {
                completion([])
            }
        })
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if lists.count != nil {
            return lists.count
            
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! ListTableViewCell
        print(lists)
        let oneList = lists[indexPath.row]
        cell.textLabel?.text = oneList.title
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
        performSegue(withIdentifier: "editList", sender: nil)

        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        listSelectedTitle = lists[indexPath.row].title
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showList", sender: nil)
    }
    
}
