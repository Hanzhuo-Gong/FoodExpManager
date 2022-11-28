//
//  OverviewTableViewController.swift
//  FoodExp Manager
//
//  Created by Hanzhuo Gong on 11/27/22.
//

import UIKit
import CoreData

class OverviewTableViewController: SwipeTableViewController {

    
    var foodArray = [Food]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        loadItem()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func loadItem() {
        let request : NSFetchRequest<Food> = Food.fetchRequest()
        do {
            foodArray = try context.fetch(request)
            print("Food array: \(foodArray)")
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = foodArray[indexPath.row].name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        //performSegue(withIdentifier: "ItemDetail", sender: self)
        print("row clicked")
        tableView.deselectRow(at: indexPath, animated: true)
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

    func checkExpiration(_ value: Int) -> String {
        let tempString = (value > 0) ? String(value) : "Expired"
        
        return tempString
    }
}
