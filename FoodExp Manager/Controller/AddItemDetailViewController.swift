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
    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var freshLifetimeTextField: UITextField!
    @IBOutlet weak var expErrorLabel: UILabel!
    
    private let notificationPublisher = NotificationPublisher()
    let datePicker = UIDatePicker()
    
    var selectedCategoryInDetailPage : Category?
    var categoryFoodArray : [Food]?
    var prefillName: String?
    var prefillLifetime: String?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    private let validation: AddItemValidationService
    
    init(validation: AddItemValidationService) {
        self.validation = validation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.validation = AddItemValidationService()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
        createDatepicker()
        quantityTextField.delegate = self
        //print("page food array: \(categoryFoodArray ?? [])")
    }
    
    func setUpElements() {
        let categoryName = selectedCategoryInDetailPage?.name
        errorLabel.alpha = 0
        quantityTextField.text = "1"
        categoryTextField.text = categoryName
        
        // hide on keyboard when tapping outside
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        if let prefillName, let prefillLifetime {
            nameTextField.text = prefillName
            freshLifetimeTextField.text = prefillLifetime
            nameErrorLabel.isHidden = true
            expErrorLabel.isHidden = true
            
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
        
        let currentDate = Date()
        
        // Difference in day
        let diffInDays = Calendar.current.dateComponents([.day], from: currentDate, to: datePicker.date).day! + 1
        freshLifetimeTextField.text = String(diffInDays)
        
        if let expfield = expirationDateTextField.text {
            if expfield.count > 0 && diffInDays > 0 {
                expErrorLabel.isHidden = true
            }
            else if expfield.count == 0 {
                expErrorLabel.isHidden = false
            }
            
            if diffInDays <= 0 {
                expErrorLabel.isHidden = false
                expErrorLabel.text = "Past date selected, please select a valid date"
            }
        }
        
        
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
        let maxnumber = 99999
        var temp = Int(quantityTextField.text ?? "0")
        if (temp! < maxnumber) {
            temp! += 1
        }
        quantityTextField.text = String(temp!)
    }
    
    @IBAction func submitBtnPressed(_ sender: UIButton) {
        
        do {
            //Check validation
            let itemName = try self.validation.validateItemName(nameTextField.text!)
            let itemExpirationDate = try self.validation.validateExpirationdate(expirationDateTextField.text!)
            let itemQuantity = try self.validation.validateQuantity(quantityTextField.text!)
            
            let uuid = UUID().uuidString
            let name = itemName
            let quantity = itemQuantity
            let expirationDate = itemExpirationDate
            if let lifetime = freshLifetimeTextField.text {
                 
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
            
        } catch {
            let errorAlert = UIAlertController(title: "Not able to Submit", message: "Please make sure all fields have valid information", preferredStyle: .alert)
            let errorAction = UIAlertAction(title: "Dismiss", style: .default)
            errorAlert.addAction(errorAction)
            self.present(errorAlert, animated: true, completion: nil)
        }
        
        
        
        
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
    
    
    
    @IBAction func nameChanged(_ sender: Any) {
        if let namefield = nameTextField.text {
            nameErrorLabel.isHidden = (namefield.count == 0) ? false : true
        }
    }
    
    /*
    @IBAction func expChanged(_ sender: Any) {
        if let expfield = expirationDateTextField.text {
            if expfield.count == 0 {
                expErrorLabel.isHidden = false
                expErrorLabel.text = "Required"
            }
            else {
                expErrorLabel.isHidden = true
            }
        }
        
        
        let dateFormmater = DateFormatter()

        dateFormmater.dateStyle = .long
        dateFormmater.timeStyle = .none

        if let validDate = dateFormmater.date(from: expirationDateTextField.text ?? "") {
            if validDate != nil {
                expErrorLabel.isHidden = false
                expErrorLabel.text = "Invalid expiration date entered. Please use the date picker, or enter a valid date (ex November 22 2022)"
            }
            else {
                expErrorLabel.isHidden = true
            }
        }
        
    }
     */
    
    func calculateDayDifference(_ sampleDate: String) -> Int {
        let dateFormmater = DateFormatter()
        dateFormmater.dateStyle = .long
        dateFormmater.timeStyle = .none
        
        let expirationDate = dateFormmater.date(from: sampleDate) ?? Date()
        let currentDate = Date()
        
        // Difference in day
        let diffInDays = Calendar.current.dateComponents([.day], from: currentDate, to: expirationDate).day! + 1
            
        return diffInDays
    }
}

extension AddItemDetailViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 5
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)

        return newString.count <= maxLength
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
