//
//  AddItemTableViewController.swift
//  FoodExp Manager
//
//  Created by Hanzhuo Gong on 11/22/22.
//

import UIKit
import FirebaseFirestore

class AddItemTableViewController: UITableViewController {

    @IBOutlet var itemList: UITableView!
    
    var passingCategoryValue : Category?
    var passingFoodArrayValue : [Food]?
    let db = Firestore.firestore()
    var itemArray = [Item]()
    var filteredData = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        //print("Food array: \(passingFoodArrayValue ?? [])")
        tableView.rowHeight = 80.0
        
    }

    // MARK: - Table view data source
    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }*/
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return itemArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Items", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = itemArray[indexPath.row].name
        cell.detailTextLabel?.text = "⏳ \(itemArray[indexPath.row].lifetime)"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //TODO: Need to perform segue to the Item Detail Page
        performSegue(withIdentifier: "AddItemPreFill", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
        //print("add item segue triggered")
    }
    
    func loadItems() {
        itemArray = []
        
        db.collection("items").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if let name = document.data()["name"] as? String,
                       let lifetime = document.data()["lifetime"] as? String {
                        let newItem = Item(name: name, lifetime: lifetime)
                        self.itemArray.append(newItem)
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func loadItems(_ filterString: String) {
        itemArray = []
        
        db.collection("items").whereField("name", isEqualTo: filterString)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        if let name = document.data()["name"] as? String,
                           let lifetime = document.data()["lifetime"] as? String {
                            let newItem = Item(name: name, lifetime: lifetime)
                            self.itemArray.append(newItem)
                        }
                    }
                    self.tableView.reloadData()
                }
        }
    }
    
    @IBAction func customButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "AddItemDetail", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        let destinationVC = segue.destination as! AddItemDetailViewController
        destinationVC.selectedCategoryInDetailPage = passingCategoryValue
        destinationVC.categoryFoodArray = passingFoodArrayValue
        
        if segue.identifier == "AddItemPreFill" {
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.prefillName = itemArray[indexPath.row].name
                destinationVC.prefillLifetime = itemArray[indexPath.row].lifetime
            }
        }
    }
}

//MARK: - Search bar methods
extension AddItemTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //should retrieve the data from firebase with the includes method
        
        if searchBar.text?.count != 0 {
            loadItems(searchBar.text!)
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    /*
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("search button clicked")
    }
     */
}

