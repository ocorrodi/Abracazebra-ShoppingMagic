//
//  FavoritesTableViewController.swift
//  GoGo Lists
//
//  Created by Victoria Corrodi on 7/22/17.
//  Copyright © 2017 Olivia Corrodi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI

class FavoritesTableViewController: UITableViewController, FavoritesTableViewCellProtocol {
    
    var items: [Item] = []
    var listTitle: List?
    var itemToAdd: Item!
    var isAPublicItem = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "Chalkboard SE", size: 25)!]
        self.navigationController?.navigationBar.tintColor = UIColor .white

        getItems { (retrievedItems) in
            self.items = retrievedItems
            self.tableView.reloadData()
        }

    }
    
    func addThisItemToAList(cell: FavoritesTableViewCell) {
        let indexPath = tableView.indexPath(for: cell)
        let itemToAdd = items[(indexPath?.row)! ?? 0]
        self.itemToAdd = itemToAdd
        performSegue(withIdentifier: "showFavorite", sender: self)
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
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as! FavoritesTableViewCell
        let oneCell = items[indexPath.row]
        cell.delegate = self
        cell.itemLabel.text = oneCell.title
        
        
        return cell
    }
    
    func getItems(completion: @escaping ([Item]) -> Void) {
        let user = Auth.auth().currentUser
        let ref = Database.database().reference().child("users").child(user!.uid).child("lists").child("favorites and recents")
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
//                self.activityView.isHidden = true
//                self.activityView.stopAnimating()
                return completion(itemsToPass)
            } else {
//                self.activityView.isHidden = true
//                self.activityView.stopAnimating()
                return completion([])
            }
        })
        
        
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            let user = Auth.auth().currentUser
            let index = indexPath[1]
            let favoriteToBeDeleted = items[index]
            print(favoriteToBeDeleted.title)
            let ref = Database.database().reference().child("users").child((user?.uid)!).child("lists").child("favorites and recents").child(favoriteToBeDeleted.title)
            items.remove(at: index)
            tableView.reloadData()
            ref.setValue(nil)
        }
    }


    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFavorite" {
            let destinationVC = segue.destination as! ItemViewController
            destinationVC.item = itemToAdd
            destinationVC.listTitle = listTitle
            destinationVC.favorite = true
            if isAPublicItem {
                destinationVC.isAPublicItem = true
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

}
