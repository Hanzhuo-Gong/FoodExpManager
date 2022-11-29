//
//  AddItemDetailViewController.swift
//  FoodExp Manager
//
//  Created by Hanzhuo Gong on 11/22/22.
//

import UIKit
import Firebase


class AddItemDetailViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var expirationDateTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var freshLifetimeTextField: UITextField!
    
    private let notificationPublisher = NotificationPublisher()
    let datePicker = UIDatePicker()
    
    var selectedCategoryInDetailPage : Category?
    var categoryFoodArray : [Food]?
    var prefillName: String?
    var prefillLifetime: String?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
        createDatepicker()
        //print("page food array: \(categoryFoodArray ?? [])")
    }
    
    func setUpElements() {
        let categoryName = selectedCategoryInDetailPage?.name
        errorLabel.alpha = 0
        quantityTextField.text = "1"
        categoryTextField.text = categoryName
        
        if let prefillName, let prefillLifetime {
            nameTextField.text = prefillName
            freshLifetimeTextField.text = prefillLifetime
            
            let today = Date()
            let expirationDate = Calendar.current.date(byAdding: .day, value: Int(prefillLifetime)!, to: today)
            
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            expirationDateTextField.text = formatter.string(from: expirationDate!)
        }
    }
    
    func createToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneBtn], animated: true)
        
        return toolbar
    }

    func createDatepicker() {
        //Style of the datePicker
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        
        expirationDateTextField.inputView = datePicker
        expirationDateTextField.inputAccessoryView = createToolbar()
    }
    
    @objc func donePressed() {
        // formatter
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        
        expirationDateTextField.text = formatter.string(from: datePicker.date)
        
        //Testing for expiration date
        formatter.dateStyle = .short
        let expirationDateShort = formatter.string(from: datePicker.date)
        errorLabel.text = expirationDateShort
        
        let currentDate = Date()
        
        // Difference in day
        let diffInDays = Calendar.current.dateComponents([.day], from: currentDate, to: datePicker.date).day! + 1
        freshLifetimeTextField.text = String(diffInDays)
        
        self.view.endEditing(true)
    }
    
    @IBAction func substractBtnPressed(_ sender: Any) {
        var temp = Int(quantityTextField.text ?? "0")
        if(temp! > 0) {
           temp! -= 1
        }
        quantityTextField.text = String(temp!)
    }
    
    @IBAction func addBtnPressed(_ sender: Any) {
        var temp = Int(quantityTextField.text ?? "0")
        temp! += 1
        quantityTextField.text = String(temp!)
    }
    
    @IBAction func submitBtnPressed(_ sender: UIButton) {
        //if let
        let uuid = UUID().uuidString
        if let name = nameTextField.text,
           let quantity = quantityTextField.text,
           let lifetime = freshLifetimeTextField.text,
           let expirationDate = expirationDateTextField.text {
             
            let newFood = Food(context: self.context)
            newFood.id = uuid
            newFood.name = name
            newFood.quantity = quantity
            newFood.lifetime = lifetime
            newFood.expirationDate = expirationDate
            newFood.parentCategory = self.selectedCategoryInDetailPage
            
            self.saveItems()
            
            if Int(lifetime) ?? 0 <= 0 {
                print("Food will expired today, no reminder needed")
            }
            else {
                var reminderTimeInterval = 1
                let secondsInADay = 86400
                let lifeTimeInterval = Int(lifetime)! * secondsInADay
                let bodyMessage = "\(nameTextField.text ?? "Food") will expire soon. If the item still there, Please check on Overview to view the expiration date"
                // if the lifetime greater than 3, remind when 3 days left, else remind when 1 day left
                let reminderday = Int(lifetime) ?? 1 > 3 ? 3 : 1
                let reminderdayTimeInterval = reminderday * secondsInADay
                reminderTimeInterval = lifeTimeInterval - reminderdayTimeInterval
                
                if(reminderTimeInterval <= 0) {
                    reminderTimeInterval = 1
                }
                
                notificationPublisher.sendNotification(title: "Reminder", body: bodyMessage , badge: 1, delayInterval: reminderTimeInterval)
                
            }
            
        }
        performSegue(withIdentifier: "ItemAddedFromCustom", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ItemListViewController
        
        destinationVC.selectedCategory = selectedCategoryInDetailPage
    
    }
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
}

//MARK: date extension
extension TimeZone {
    static let gmt = TimeZone(secondsFromGMT: 0)!
}

extension Locale {
    static let ptBR = Locale(identifier: "pt_BR")
}

extension Formatter {
    static let date = DateFormatter()
}

extension Date {
    func localizedDescription(date dateStyle: DateFormatter.Style = .medium,
                              time timeStyle: DateFormatter.Style = .none,
                              in timeZone: TimeZone = .current,
                              locale: Locale = .current,
                              using calendar: Calendar = .current) -> String {
        Formatter.date.calendar = calendar
        Formatter.date.locale = locale
        Formatter.date.timeZone = timeZone
        Formatter.date.dateStyle = dateStyle
        Formatter.date.timeStyle = timeStyle
        return Formatter.date.string(from: self)
    }
    var localizedDescription: String { localizedDescription() }
}
