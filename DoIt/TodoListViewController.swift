//
//  ViewController.swift
//  DoIt
//
//  Created by Jeremy Rufo
//

import UIKit

class TodoListViewController: UITableViewController {
    
    var itemArray = ["Find Mike", "Buy Eggos", "Destroy Demogorgon"]
    
    // An interface to the user’s defaults database, where one stores
    // key-value pairs persistently across launches of the app
    let userDefaults = UserDefaults.standard
    
    var selectedItems: [String: Bool] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let items = userDefaults.array(forKey: K.keyValueNameForList) as? [String] {
            itemArray = items
        }
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get the reusable cell
        let cell = tableView.dequeueReusableCell(withIdentifier: K.reusableCellName, for: indexPath)
        
        // Set the cell's default label
        cell.textLabel?.text = self.itemArray[indexPath.row]
        
        return cell
    }
    
    //MARK: - TableView Delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Unselect the row
        tableView.deselectRow(at: indexPath, animated: false)
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        // Get the corresponding item in our array
        let item = itemArray[indexPath.row]
        
        // See if we have a current value for it, or not
        if let result = selectedItems[item] {
            cell.accessoryType = !result ? .checkmark : .none
            selectedItems[item] = !result
            print("\(item) is \(!result ? "checked" : "not checked")")
        } else {
            cell.accessoryType = .checkmark
            selectedItems[item] = true
            print("\(item) is checked")
        }
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add New Item", message: nil, preferredStyle: .alert)
        
        // Add a cancel button
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Create a text field to be used to extend the scope of the alert text field
        //var enteredText = ""
        alert.addTextField(configurationHandler: { alertTextField in
            alertTextField.placeholder = "Enter items here..."
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            // Grab the text out of the alert text field and save it
            if let text = alert.textFields?.first?.text {
                
                // Save the new item to our local list
                self.itemArray.append(text)
                
                // Save our local list to the persistent iOS App Data
                // (we probably want to move this into a save area at some point)
                self.userDefaults.setValue(self.itemArray, forKey: K.keyValueNameForList)
                
                // Reload our table to show the new data
                self.tableView.reloadData()
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
}
