//
//  Category_Test.swift
//  FoodExp ManagerTests
//
//  Created by Hanzhuo Gong on 10/31/22.
//

import XCTest
@testable import FoodExp_Manager



final class Category_Test: XCTestCase {

    var validation : CategoryValidationService!
    
    override func setUp() {
        super.setUp()
        validation = CategoryValidationService()
    }
    
    override func tearDown() {
        validation = nil
        super.tearDown()
    }
    
    //MARK: Pass cases
    func test_is_valid_category_name_1() throws {
        XCTAssertNoThrow(try validation.validateCategoryName("Apple"))
    }
    
    func test_is_valid_category_name_2() throws {
        XCTAssertNoThrow(try validation.validateCategoryName("Favorite food for myself"))
    }
    
    //MARK: Fail cases
    func test_category_name_is_nil() throws {
        let expectedError = ValidationError.invalidString
        var error: ValidationError?
        
        XCTAssertThrowsError(try validation.validateCategoryName(nil)) { thrownError in
            error = thrownError as? ValidationError
        }
        
        XCTAssertEqual(expectedError, error)
    }
    
    func test_category_name_is_empty() throws {
        let expectedError = ValidationError.categoryNameTooShort
        var error: ValidationError?
        
        XCTAssertThrowsError(try validation.validateCategoryName("")) { thrownError in
            error = thrownError as? ValidationError
        }
        
        XCTAssertEqual(expectedError, error)
    }
    
}
