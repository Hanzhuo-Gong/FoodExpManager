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
    
}

enum AddItemValidationError: LocalizedError {
    case invalidItemName
    case itemNameTooShort
    
    var errorDescription: String? {
        switch self {
        case .invalidItemName:
            return "Invalid item name, name is not a string"
        case .itemNameTooShort:
            return "Item name can't not be empty, please re-enter"
        }
    }
}
