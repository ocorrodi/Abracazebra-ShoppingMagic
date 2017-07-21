//
//  AddItemViewController.swift
//  GoGo Lists
//
//  Created by Victoria Corrodi on 7/14/17.
//  Copyright © 2017 Olivia Corrodi. All rights reserved.
//

import UIKit

class AddItemViewController: UIViewController {
    
    var listTitle: String = ""
    var itemIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

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

        }
        if segue.identifier == "toBarcodeScanner" {
            let destinationVC = segue.destination as! BarcodeScanningViewController
            destinationVC.listTitle = self.listTitle

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