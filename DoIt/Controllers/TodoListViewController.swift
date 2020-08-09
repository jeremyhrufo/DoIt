//
//  ViewController.swift
//  DoIt
//
//  Created by Jeremy Rufo
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {

    var itemArray: [Item] = [Item]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad () {
        super.viewDidLoad()
        retrieveData()
    }

    //MARK: - Tableview Datasource Methods

    override func tableView (_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.itemArray.count
    }

    override func tableView (_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get the reusable cell
        let cell = tableView.dequeueReusableCell(withIdentifier: K.reusableCellName, for: indexPath)
        let item = self.itemArray[indexPath.row]

        // Set default label and accessory and return the cell
        cell.textLabel?.text = item.title
        cell.accessoryType = item.isDone ? .checkmark : .none
        return cell
    }

    //MARK: - TableView Delegate methods

    override func tableView (_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Unselect our row; get item and reverse isDone flag; save and reload the table
        tableView.deselectRow(at: indexPath, animated: false)
        itemArray[indexPath.row].isDone = !itemArray[indexPath.row].isDone
        self.saveData()
    }

    //MARK: - Add New Items

    @IBAction func addButtonPressed (_ sender: UIBarButtonItem) {
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
                    self.saveData()
                }
            }
        }))

        present(alert, animated: true, completion: nil)
    }

    //MARK: - Storage

    func retrieveData () {
        do {
            // Need to specify the data type
            let request : NSFetchRequest<Item> = Item.fetchRequest()
            self.itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context, \(error)")
        }
    }

    func saveData () {
        // Save our data in core data
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }

        // reload our table
        self.tableView?.reloadData()
    }

    //MARK: - Utility functions

    // Add an item to our local array if the string passed in isn't empty
    func addItem (_ title: String, _ isDone: Bool = false) -> Bool {
        if title.isEmpty {
            return false
        }

        self.itemArray.append(self.createItem(title))
        return true
    }

    func createItem (_ title: String, _ isDone: Bool = false) -> Item {
        let item = Item(context: self.context)
        item.title = title
        item.isDone = isDone
        return item
    }
}
