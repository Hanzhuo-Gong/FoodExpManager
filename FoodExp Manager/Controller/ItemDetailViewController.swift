//
//  ItemDetailViewController.swift
//  FoodExp Manager
//
//  Created by Hanzhuo Gong on 11/22/22.
//

import UIKit
import FirebaseFirestore

class ItemDetailViewController: UIViewController {

    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lifeTimeTextField: UITextField!
    @IBOutlet weak var expirationDateTextField: UITextField!
    
    var selectedFood : Food?
    var selectedFoodCategory : Category?
    let datePicker = UIDatePicker()
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpElements()
        createDatepicker()
    }
    
    func setUpElements() {
        categoryTextField.text = selectedFoodCategory?.name
        expirationDateTextField.text = selectedFood?.expirationDate
        quantityTextField.text = selectedFood?.quantity
        nameTextField.text = selectedFood?.name
        lifeTimeTextField.text = selectedFood?.lifetime
        expirationDateLabel.alpha = 0
        
        //Calculate how much time left before expiration
        let dateFormmater = DateFormatter()
        dateFormmater.dateStyle = .long
        
        if let expirationDate = dateFormmater.date(from: selectedFood?.expirationDate ?? "") {
            let currentDate = Date()
            
            // Difference in day
            let diffInDays = Calendar.current.dateComponents([.day], from: currentDate, to: expirationDate).day! + 1
            
            expirationDateLabel.text = checkExpiration(diffInDays)
            expirationDateLabel.alpha = 1
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
        lifeTimeTextField.text = String(diffInDays)
        expirationDateLabel.text = checkExpiration(diffInDays)
        
        self.view.endEditing(true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func checkExpiration(_ value: Int) -> String {
        var tempString = ""
        
        if value > 1 {
            tempString = "\(String(value)) days left before expiration"
        }
        else if value < 0 {
            tempString = "Food already expired"
        }
        else if value == 0 {
            tempString = "Food will expire today"
        }
        else {
            tempString = "\(String(value)) day left before expiration"
        }
        
        return tempString
    }
    
    @IBAction func updateBtnPressed(_ sender: UIButton) {
        print("update button pressed")
    }
    
    @IBAction func shareBtnPressed(_ sender: UIButton) {
        let alertMessage = "Share your prefilled data. Others can find your item in the search"
        
        let alert = UIAlertController(title: "Share the Item", message: alertMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "Share", style: .default) { (action) in
            
            //TODO: need to check whether the data exist or not, if exist, update the value instead of create a new one
            if let itemCategory = self.selectedFoodCategory?.name,
               let itemName = self.selectedFood?.name,
               let itemLifeTime = self.selectedFood?.lifetime,
               let itemID = self.selectedFood?.id {
                
                // Add a new document with a generated ID
                var ref: DocumentReference? = nil
                ref = self.db.collection("items").addDocument(data: [
                    "id": itemID,
                    "category": itemCategory,
                    "name": itemName,
                    "lifetime": itemLifeTime
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                    }
                }
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
            //Cancel action, no code is required in here
        }

        alert.addAction(cancelAction)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
         
    }
    @IBAction func FavoriteBtnPressed(_ sender: UIButton) {
        print("favorite button pressed")
    }
}
