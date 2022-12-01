//
//  FavoriteTableViewController.swift
//  FoodExp Manager
//
//  Created by Hanzhuo Gong on 11/27/22.
//

import UIKit
import CoreData

class FavoriteTableViewController: SwipeTableViewController {
    
    var favroiteFoodArray = [FavoriteFood]()

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        loadFavoriteFood()
        
    }

    func loadFavoriteFood() {
        let request : NSFetchRequest<FavoriteFood> = FavoriteFood.fetchRequest()
        
        do {
            favroiteFoodArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
    }
    
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favroiteFoodArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        /*
        let quantityString = "QTY: \(favroiteFoodArray[indexPath.row].quantity ?? "0")  "
        let lifetimeString = "⏳ \(favroiteFoodArray[indexPath.row].lifetime ?? "0")"
        let combineString = quantityString + lifetimeString
         */
        cell.textLabel?.text = favroiteFoodArray[indexPath.row].name
        cell.detailTextLabel?.text = "⏳ \(favroiteFoodArray[indexPath.row].lifetime ?? "0")"
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "favoriteAddedItem", sender: self)
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! FavoriteAddItemViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedFavoriteFood = favroiteFoodArray[indexPath.row]
        }
    }
    
    
    override func updateModel(at indexPath: IndexPath) {
        context.delete(favroiteFoodArray[indexPath.row])
        favroiteFoodArray.remove(at: indexPath.row)
        //self.saveCategories()

        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    @IBAction func refreshedBtnPressed(_ sender: UIBarButtonItem) {
        loadFavoriteFood()
    }
    
}
