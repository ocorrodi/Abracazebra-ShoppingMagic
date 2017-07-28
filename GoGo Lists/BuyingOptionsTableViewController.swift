//
//  BuyingOptionsTableViewController.swift
//  GoGo Lists
//
//  Created by Victoria Corrodi on 7/19/17.
//  Copyright © 2017 Olivia Corrodi. All rights reserved.
//

import UIKit

class BuyingOptionsTableViewController: UITableViewController, BuyingOptionsTableViewCellProtocol {
    
    var item: Item = Item(title: "", brand: "", price: "", barcode: "", imageURL: "", buyingOptions: [], favorite: false)
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(item)
        let cell = tableView.dequeueReusableCell(withIdentifier: "buyCell", for: indexPath) as! BuyingOptionsTableViewCell
        
        cell.row = indexPath.row
        cell.delegate = self
        let oneList = item.buyingOptions[indexPath.row]
        print(oneList)
        
        cell.merchantLabel.text = oneList.name
        if oneList.price == 0.00 {
            cell.sellingPriceLabel.text = "not available"
        }
        else {
            cell.sellingPriceLabel.text = "price: \(oneList.price!)"
        }
        

        return cell
    }
    
    func sendRow(row: Int) {
        let itemToBuy = item.buyingOptions[row].link
        
        UIApplication.shared.open(URL(string: itemToBuy!)!, options: [:], completionHandler: nil)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

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
       /* if item.buyingOptions[0].count == 1 {
            return 0
        }
        else {
            return item.buyingOptions.count
        } */
        return item.buyingOptions.count
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "Chalkboard SE", size: 25)!]
        self.navigationController?.navigationBar.tintColor = UIColor .white

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
