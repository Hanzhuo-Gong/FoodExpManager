//
//  CategoryViewController.swift
//  FoodExp Manager
//
//  Created by Hanzhuo Gong on 10/24/22.
//

import UIKit
import CoreData


class CategoryViewController: SwipeTableViewController {

    var categoryArray = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    //Initialize the Category Service
    private let validation: CategoryValidationService
    
    init(validation: CategoryValidationService) {
        self.validation = validation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.validation = CategoryValidationService()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 80.0
        loadCategories()
        
    }

    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name
        //cell.delegate = self
        
        return cell
    }

    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Need to perfrom a segue
        performSegue(withIdentifier: "goToFood", sender: self)
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ItemListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    
    //MARK: - TableView Manipulation Methods
    func saveCategories() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadCategories() {
        
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
    }

    //MARK: - Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {
        context.delete(categoryArray[indexPath.row])
        categoryArray.remove(at: indexPath.row)
        //self.saveCategories()

        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            do {
                let categoryName = try self.validation.validateCategoryName(textField.text!)
                let newCategory = Category(context: self.context)
                newCategory.name = categoryName
                self.categoryArray.append(newCategory)
                self.saveCategories()
            } catch {
                
                let errorAlert = UIAlertController(title: "Invalid Category Name", message: "Category can't be empty \nplease enter again", preferredStyle: .alert)
                let errorAction = UIAlertAction(title: "Dismiss", style: .default)
                errorAlert.addAction(errorAction)
                self.present(errorAlert, animated: true, completion: nil)
            }
            
            
//            let newCategory = Category(context: self.context)
//            newCategory.name = textField.text!
//            self.categoryArray.append(newCategory)
//            self.saveCategories()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
            //Cancel action, no code is required in here
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add new category"
        }
        
        present(alert, animated: true,completion: nil)
    }
    
    
}

//extension UIAlertController {
//
//    func isValidCategoryName(_ name: String) -> Bool {
//
//        return name.count > 0
//    }
//
//    func textDidChangeInLoginAlert() {
//        if let categoryName = textFields?[0].text,
//
//            let action = actions.last {
//            action.isEnabled = isValidCategoryName(categoryName)
//        }
//    }
//}
