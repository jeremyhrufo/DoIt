//
//  ViewController.swift
//  DoIt
//
//  Created by Jeremy Rufo
//

import UIKit

class TodoListViewController: UITableViewController {
    
    var itemArray: [DoItItem] = [
        DoItItem("Find Mike"), DoItItem("Buy Eggos"), DoItItem("Destroy Demogorgon")]
    
    let dataFilePath =
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(K.doItItemsPListName)
    
    // An interface to the user’s defaults database, where one stores
    // key-value pairs persistently across launches of the app
    // Should only be used for small bits of data - it's not a database!
    // UserDefaults.standard is a Singleton
    // let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveDoItList()
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get the reusable cell
        let cell = tableView.dequeueReusableCell(withIdentifier: K.reusableCellName, for: indexPath)
        let item = self.itemArray[indexPath.row]
        
        // Set default label and accessory and return the cell
        cell.textLabel?.text = item.title
        cell.accessoryType = item.isDone ? .checkmark : .none
        return cell
    }
    
    //MARK: - TableView Delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Unselect our row; get item and reverse isDone flag; save and reload the table
        tableView.deselectRow(at: indexPath, animated: false)
        itemArray[indexPath.row].isDone = !itemArray[indexPath.row].isDone
        self.saveAndReloadTable()
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Item", message: nil, preferredStyle: .alert)
        
        // Add a cancel button
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Create a text field to be used to extend the scope of the alert text field
        alert.addTextField(configurationHandler: { alertTextField in
            alertTextField.placeholder = "Enter items here..."
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            // Grab the text out of the alert text field and save it
            if let text = alert.textFields?.first?.text {
                if self.addItem(text) {
                    self.saveAndReloadTable()
                }
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Saving/Retrieving to our own plist
    
    func retrieveDoItList() {
        do {
            let data = try Data(contentsOf: self.dataFilePath!)
            itemArray = try PropertyListDecoder().decode([DoItItem].self, from: data)
        } catch { print("Error encoding, \(error)") }
    }
    
    // Save our local list to the our own plist file
    func saveDoItList() {
        do {
            let data = try PropertyListEncoder().encode(itemArray)
            try data.write(to: self.dataFilePath!)
        } catch { print("Error encoding, \(error)") }
    }
    
    //MARK: - Saving/Retrieving to the UserDefaults.standard
    
    /* Saving the UserDefaults way
     // Save our local list to the persistent iOS App Data UserDefaults
     func saveDoItList() {
        userDefaults.set(try? PropertyListEncoder().encode(itemArray), forKey: K.keyValueNameForList)
     } */
    
    /* Retrieving the UserDefaults way
     func retrieveDoItList() {
        if let tempData = userDefaults.object(forKey: K.keyValueNameForList) as? Data {
            if let tempArray = try? PropertyListDecoder().decode([DoItItem].self, from: tempData) {
                itemArray = tempArray
            }
        }
     } */
    
    //MARK: - Other functions we want to keep out of the way
    
    // Reload our table to show the new data
    func reloadTable() {
        self.tableView?.reloadData()
    }
    
    // Add an item to our local array if the string passed in isn't empty
    func addItem(_ title: String) -> Bool {
        if title.isEmpty { return false }
        self.itemArray.append(DoItItem(title))
        return true
    }
    
    // Save our local DoIt list to UserDefaults
    // Reload our table with updated values
    func saveAndReloadTable() {
        self.saveDoItList()
        self.reloadTable()
    }
}
