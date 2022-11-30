//
//  OverviewTableViewController.swift
//  FoodExp Manager
//
//  Created by Hanzhuo Gong on 11/27/22.
//

import UIKit
import CoreData
import UserNotifications

class OverviewTableViewController: SwipeTableViewController {

    var foodArray = [Food]()
    var sortedFoodArray = [Food]()
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80.0
        loadItem()
        
    }
    
    /*
    //MARK: Local Notification
    func localNotificationSetUp() {
        
        // ask for user's permission
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Hey I'm a notification!"
        content.body = "Look at me!"
        
        // Create the nofitication trigger
        let date = Date().addingTimeInterval(5)
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // Create the request
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        //Register the request
        center.add(request) { (error) in
            print(error)
        }
    }
    */
    
    // pull to refresh
    @IBAction func refreshTable(_ sender: UIRefreshControl) {
        loadItem()
        sender.endRefreshing()
    }
    
    
    func loadItem() {
        foodArray = []
        sortedFoodArray = []
        
        let request : NSFetchRequest<Food> = Food.fetchRequest()
        do {
            foodArray = try context.fetch(request)
            sortedFoodArray = sortFoodArray(foodArray)
            foodArray = sortedFoodArray
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
    
    func sortFoodArray(_ sampleFoodArray: [Food]) -> [Food] {
        var remainDaysArray = [Int]()
        
        for element in sampleFoodArray {
            remainDaysArray.append(calculateDayDifference(element.expirationDate ?? ""))
        }
        
        for _ in 0...remainDaysArray.count-1 {
            var smallestIndex = 0
            var smallestNumber = 2147483647
            
            for range in 0...remainDaysArray.count-1 {
              if remainDaysArray[range] < smallestNumber {
                smallestNumber = remainDaysArray[range]
                smallestIndex = range
              }
            }
            sortedFoodArray.append(sampleFoodArray[smallestIndex])
            remainDaysArray[smallestIndex] = 2147483647
            
        }
        return sortedFoodArray
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
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let itemExpirationDate = foodArray[indexPath.row].expirationDate
        var expirationString = ""
        
        let dateFormmater = DateFormatter()
        dateFormmater.dateStyle = .long
        dateFormmater.timeStyle = .none
        
        if let expirationDate = dateFormmater.date(from: itemExpirationDate ?? "") {
            let currentDate = Date()
            
            // Difference in day
            let diffInDays = Calendar.current.dateComponents([.day], from: currentDate, to: expirationDate).day! + 1
            expirationString = checkExpiration(diffInDays)
        }
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = foodArray[indexPath.row].name
        cell.detailTextLabel?.text = "⏳ \(expirationString)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        //performSegue(withIdentifier: "ItemDetail", sender: self)
        print("row clicked")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func updateModel(at indexPath: IndexPath) {
        //Delete item for testing
        context.delete(foodArray[indexPath.row])
        foodArray.remove(at: indexPath.row)
        
        do {
            try self.context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }

    func checkExpiration(_ value: Int) -> String {
        let tempString = (value > 0) ? String(value) : "Expired"
        
        return tempString
    }
}
