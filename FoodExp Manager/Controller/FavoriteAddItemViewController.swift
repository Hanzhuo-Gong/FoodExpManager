//
//  FavoriteAddItemViewController.swift
//  FoodExp Manager
//
//  Created by Hanzhuo Gong on 11/30/22.
//

import UIKit
import CoreData

class FavoriteAddItemViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var expirationDateTextField: UITextField!
    @IBOutlet weak var lifetimeTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var errorTextLabel: UILabel!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    
    
    var selectedFavoriteFood : FavoriteFood?
    var categoryArray = [Category]()
    var categoryNameArray = [String]()
    var selectedIndex : Int?
    var pickerView = UIPickerView()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadInformation()
        loadCategories()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        categoryTextField.inputView = pickerView
    }
    
    func loadInformation() {
        nameTextField.text = selectedFavoriteFood?.name
        lifetimeTextField.text = selectedFavoriteFood?.lifetime
        quantityTextField.text = selectedFavoriteFood?.quantity
        
        if let prefillLifetime = selectedFavoriteFood?.lifetime {
            let today = Date()
            let expirationDate = Calendar.current.date(byAdding: .day, value: Int(prefillLifetime)!, to: today)
            
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            expirationDateTextField.text = formatter.string(from: expirationDate!)
        }
        
        submitBtn.layer.cornerRadius = submitBtn.frame.height / 2
    }
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
    }
    
    func loadCategories() {
        
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            categoryArray = try context.fetch(request)
            
            if categoryArray.count > 0 {
                for index in 0...categoryArray.count-1 {
                    categoryNameArray.append(categoryArray[index].name ?? "")
                }
               // print(categoryNameArray)
            }
            
        } catch {
            print("Error fetching data from context \(error)")
        }
        
    }

    @IBAction func categoryChanged(_ sender: Any) {
        if let categoryfield = categoryTextField.text {
            errorTextLabel.isHidden = (categoryfield.count == 0) ? false : true
        }
    }
    @IBAction func submitBtnPressed(_ sender: UIButton) {
        
        let uuid = UUID().uuidString
        if let name = nameTextField.text,
            let quantity = quantityTextField.text,
            let expirationDate = expirationDateTextField.text,
            let lifetime = lifetimeTextField.text,
            let categoryIndex = selectedIndex {
            
            let newFood = Food(context: self.context)
            newFood.id = uuid
            newFood.name = name
            newFood.quantity = quantity
            newFood.lifetime = lifetime
            newFood.expirationDate = expirationDate
            newFood.parentCategory = categoryArray[categoryIndex]
            
            self.saveItems()
            
            let confirmAlert = UIAlertController(title: "Succeed!", message: "", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "Dismiss", style: .default)
            confirmAlert.addAction(confirmAction)
            self.present(confirmAlert, animated: true, completion: nil)
        }
        
    }
}

extension FavoriteAddItemViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryNameArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryNameArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if categoryNameArray.count > 0 {
            categoryTextField.text = categoryNameArray[row]
            categoryTextField.resignFirstResponder()
            selectedIndex = row
            errorTextLabel.isHidden = true
        } else {
            let errorAlert = UIAlertController(title: "Not able to Submit", message: "Please make sure you have at least one category to add the item", preferredStyle: .alert)
            let errorAction = UIAlertAction(title: "Dismiss", style: .default)
            errorAlert.addAction(errorAction)
            categoryTextField.resignFirstResponder()
            self.present(errorAlert, animated: true, completion: nil)
            
        }
        
    }
}
