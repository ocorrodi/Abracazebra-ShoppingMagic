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

class IndividualListTableViewController: UITableViewController {
    
    
    
    @IBOutlet weak var navigationControllerTitle: UINavigationItem!
    
    var listTitle: String = ""
    var listIndex: Int = 0
    var items: [Item] = []
    var itemSelected: Item = Item(title: "", brand: "", price: "", barcode: "", imageURL: " ", buyingOptions: [[" "]])
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationControllerTitle.title = listTitle
        
    
        
        getItems { (retrievedItems) in
            self.items = retrievedItems
            self.tableView.reloadData()
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
            destinationVC.listTitle = self.listTitle
            destinationVC.itemIndex = self.listIndex
        }
        if segue.identifier == "showItem" {
            let destinationVC = segue.destination as! ItemViewController
            print(itemSelected)
            destinationVC.item = itemSelected
            destinationVC.listTitle = listTitle
            destinationVC.editingTheItem = true

            
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemTableViewCell
        let oneList = items[indexPath.row]
        cell.textLabel?.text = oneList.title
        return cell
    }

    
    func getItems(completion: @escaping ([Item]) -> Void) {
        let user = Auth.auth().currentUser
        let ref = Database.database().reference().child("users").child(user!.uid).child("lists").child(listTitle)
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let valueList = snapshot.value as? NSDictionary as? [String: [String : Any]] {
                var itemsToPass = [Item]()
                for item in valueList.keys {
                    if item != "dummyItemName" {
                        let buyingOptions2 = valueList[item]!["buyingOptions"]! as? NSArray as? [[String]]
    
                        itemsToPass.append(Item(title: item, brand: valueList[item]!["brand"]! as! String, price: valueList[item]!["price"]! as! String, barcode: valueList[item]!["barcode"]! as! String, imageURL: valueList[item]!["imageURL"]! as! String, buyingOptions: buyingOptions2!))
                    }
                }
                print(itemsToPass)
                
                return completion(itemsToPass)
            } else {
                return completion([])
            }
        })

    }
    @IBAction func unwindToList(segue:UIStoryboardSegue) {
        getItems { (retrievedItems) in
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
        if editingStyle == .delete {
            let user = Auth.auth().currentUser
            let index = indexPath[1]
            let itemToBeDeleted = items[index]
            print(itemToBeDeleted.title)
            let ref = Database.database().reference().child("users").child((user?.uid)!).child("lists").child(listTitle).child(itemToBeDeleted.title)
            items.remove(at: index)
            tableView.reloadData()
            ref.setValue(nil)
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
}
