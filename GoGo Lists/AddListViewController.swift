//
//  AddListViewController.swift
//  GoGo Lists
//
//  Created by Victoria Corrodi on 7/12/17.
//  Copyright © 2017 Olivia Corrodi. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseAuthUI



class AddListViewController: UIViewController {
    
    @IBOutlet weak var listTitleText: UITextField!
    var lists: [String] = []
    var VC = ListsTableViewController()
    var editList = false
    var addList = false
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        print(addList)
        print(editList)
        if addList == true {
            performSegue(withIdentifier: "toLists", sender: self)
            addList = false
        }
        if editList == true {
            performSegue(withIdentifier: "backToLists", sender: self)
            editList = false
        }
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.identifier)
        if segue.identifier! == "toLists" {
            let destinationVC = segue.destination as! ListsTableViewController
            destinationVC.newList.title = listTitleText.text!
        }
        if segue.identifier! == "backToLists" {
            let destinationVC = segue.destination as! ListsTableViewController
            destinationVC.editedList.title = listTitleText.text!
        }
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

