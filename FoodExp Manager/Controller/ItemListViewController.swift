//
//  ViewController.swift
//  FoodExp Manager
//
//  Created by Hanzhuo Gong on 10/16/22.
//

import UIKit
import CoreData
import SwipeCellKit

class ItemListViewController: SwipeTableViewController {
    
    var foodArray = [Food]()
    //TODO: Check if I have to delete the didSet, because need  to send this variable to add Item
    var selectedCategory : Category? {
        //when a selectedCategory is selected, load the corresponding items in that category
        
        didSet {
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.rowHeight = 80.0
        //loadItems()
    }

    //MARK - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = foodArray[indexPath.row].name
        
        return cell
    }
    
    //MARK - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //TODO: Need to perform segue to the Item Detail Page
        performSegue(withIdentifier: "ItemDetail", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        //TODO - Create a New UI for the food page, and place the function in there
        performSegue(withIdentifier: "AddItem", sender: self)
        /*
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Food", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            let newFood = Food(context: self.context)
            newFood.name = textField.text
            newFood.parentCategory = self.selectedCategory
            self.foodArray.append(newFood)
            self.saveItems()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
            //Cancel action, no code is required in here
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new food"
            textField = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
         */
    }
    
    
    //Update CoreData value
    //foodArray[indexPath.row].setValue("Completed", forKey: "title")
    
    
    //MARK - Model Manupulation Methods
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Food> = Food.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        //Since the predicate is option, need a safe method to check if data is safe to continue
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            foodArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        //Delete item for testing
        context.delete(foodArray[indexPath.row])
        foodArray.remove(at: indexPath.row)
        
        do {
            try self.context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
}
/*
//NARK: Swipe Cell Deletegate Methods
extension ItemListViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            self.updateModel(at: indexPath)
                        
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
    
}
*/
 
//MARK: - Search bar methods
extension ItemListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //TODO: change to firebase fetchrequest later
        let request : NSFetchRequest<Food> = Food.fetchRequest()
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

