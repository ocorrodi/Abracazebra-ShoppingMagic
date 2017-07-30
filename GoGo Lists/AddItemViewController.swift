//
//  AddItemViewController.swift
//  GoGo Lists
//
//  Created by Victoria Corrodi on 7/14/17.
//  Copyright © 2017 Olivia Corrodi. All rights reserved.
//

import UIKit

class AddItemViewController: UIViewController {
    
    var listTitle: List?
    var itemIndex = 0
    var isAPublicItem = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addByText" {
            let destinationVC = segue.destination as! ItemViewController
            destinationVC.listTitle = self.listTitle
            if isAPublicItem {
                destinationVC.isAPublicItem = true
            }

        }
        if segue.identifier == "toBarcodeScanner" {
            let destinationVC = segue.destination as! BarcodeScanningViewController
            destinationVC.listTitle = listTitle
            if isAPublicItem {
                destinationVC.isAPublicItem = true
            }


        }
        if segue.identifier == "toFavorites" {
            let destinationVC = segue.destination as! FavoritesTableViewController
            destinationVC.listTitle = listTitle
            if isAPublicItem {
                destinationVC.isAPublicItem = true
            }

        }
//        destinationVC.itemIndex = self.itemIndex
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
