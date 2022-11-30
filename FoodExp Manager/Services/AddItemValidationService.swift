//
//  AddItemValidationService.swift
//  FoodExp Manager
//
//  Created by Hanzhuo Gong on 11/29/22.
//

import Foundation

struct AddItemValidationService {
    
    func validateItemName(_ itemName: String?) throws -> String {
        guard let testItemName = itemName else {throw AddItemValidationError.invalidItemName}
        guard testItemName.count > 0 else { throw AddItemValidationError.itemNameTooShort}
        return testItemName
    }
    
    func validateExpirationdate(_ expirationDate: String?) throws -> String {
        guard let testExpirationDate = expirationDate else {throw AddItemValidationError.invalidExpirationDate}
        guard testExpirationDate.count > 0 else {throw AddItemValidationError.emptyExpirationDate}
        let checkValidDate = calculateDayDifference(testExpirationDate)
        guard checkValidDate > 0 else {throw AddItemValidationError.pastDateEntered}
        return testExpirationDate
    }
    
    // lifetime bind with expirationdate, if separate future, need this validation
    /*
    func validateLifeTime(_ lifeTime: String?) throws -> String {
        
    }*/
    
    func validateQuantity(_ quantity: String?) throws -> String {
        let testQuantity = Int(quantity ?? "0")!
        guard testQuantity > 0 else {throw AddItemValidationError.invalidQuantity}
        //guard testQuantity != nil else {throw AddItemValidationError.quantityTooLarge}
        return String(testQuantity)
    }
}

enum AddItemValidationError: LocalizedError {
    case invalidItemName
    case itemNameTooShort
    
    case invalidExpirationDate
    case emptyExpirationDate
    case pastDateEntered
    
    case invalidQuantity
    case quantityTooLarge
    
    var errorDescription: String? {
        switch self {
        case .invalidItemName:
            return "Invalid item name, name is not a string"
        case .itemNameTooShort:
            return "Item name can't not be empty, please re-enter"
        case .invalidExpirationDate:
            return "Invalid expiration date in add item"
        case .emptyExpirationDate:
            return "No Expiration entered"
        case .pastDateEntered:
            return "Invalid expiration date: Past date entered"
        case .invalidQuantity:
            return "Quantity can't be less than 1"
        case .quantityTooLarge:
            return "Quantity too large"
        }
    }
}


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
