//
//  CategoryViewController.swift
//  FoodExp Manager
//
//  Created by Hanzhuo Gong on 10/24/22.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        print("Category add item pressed")
    }
    
    
    //MARK: - TableView Datasource Methods
    
    //MARK: - TableView Delegate Methods
    
    //MARK: - TableView Manipulation Methods
}
