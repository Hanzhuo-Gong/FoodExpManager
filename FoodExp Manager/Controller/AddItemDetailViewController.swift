//
//  AddItemDetailViewController.swift
//  FoodExp Manager
//
//  Created by Hanzhuo Gong on 11/22/22.
//

import UIKit

class AddItemDetailViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var expirationDateTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
        createDatepicker()
        
        
    }
    
    func setUpElements() {
        //errorLabel.alpha = 0
        nameTextField.text = "Banana"
        quantityTextField.text = "6"
        categoryTextField.text = "Fruite"
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
        print(expirationDateShort)
        
        let currentDate = Date().localizedDescription(date: .short)
        print(currentDate)
        
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
