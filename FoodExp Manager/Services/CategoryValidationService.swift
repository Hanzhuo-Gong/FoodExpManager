//
//  CategoryValidationService.swift
//  FoodExp Manager
//
//  Created by Hanzhuo Gong on 10/31/22.
//

import Foundation

struct CategoryValidationService {
    
    func validateCategoryName(_ categoryName: String?) throws -> String {
        guard let testCategoryName = categoryName else { throw ValidationError.invalidString}
        guard testCategoryName.count > 0 else { throw ValidationError.categoryNameTooShort}
        return testCategoryName
    }
}

enum ValidationError: LocalizedError {
    case invalidString
    case categoryNameTooShort
    
    var errorDescription: String? {
        switch self {
        case .invalidString:
            return "Invalid category name, name is not a string"
        case .categoryNameTooShort:
            return "Category name can't not be empty, please re-enter"
        }
    }
}
