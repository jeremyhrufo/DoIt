//
//  ViewController.swift
//  DoIt
//
//  Created by Jeremy Rufo
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    //MARK: - Members
    var itemArray: [Item] = [Item]()
    var selectedCategory: Category? {
        didSet {
            // Once 'selectedCategory' is set with a value, retrieve our data
            retrieveData()
        }
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    //MARK: - Normal functionality
    override func viewDidLoad () {
        super.viewDidLoad()
    }

    @IBAction func addButtonPressed (_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Item", message: nil, preferredStyle: .alert)

        // Add a cancel button
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        // Create a text field to be used to extend the scope of the alert text field
        alert.addTextField(configurationHandler: { alertTextField in
            alertTextField.placeholder = "Enter item description here..."
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
}

//MARK: - Tableview Datasource Methods
extension TodoListViewController {
    override func tableView (_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemArray.count
    }

    override func tableView (_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get the reusable cell
        let cell = tableView.dequeueReusableCell(withIdentifier: K.itemReusableCellName, for: indexPath)
        let item = self.itemArray[indexPath.row]

        // Set default label and accessory and return the cell
        cell.textLabel?.text = item.title
        cell.accessoryType = item.isDone ? .checkmark : .none
        return cell
    }
}

//MARK: - TableView Delegate methods
extension TodoListViewController {
    override func tableView (_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Unselect our row; get item and reverse isDone flag; save and reload the table
        tableView.deselectRow(at: indexPath, animated: false)
        itemArray[indexPath.row].isDone = !itemArray[indexPath.row].isDone
        self.saveData()
    }
}

//MARK: - Storage functions
extension TodoListViewController {
    // Retrieve our data with passed in NSFetchRequest
    func retrieveData (with request: NSFetchRequest<Item> = Item.fetchRequest()) {

        // Here is our category predicate
        var predicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)

        // If our request already have a predicate, add them both to a compound predicate
        // I don't know, yet, if I can add a compound predicate to another one
        if request.predicate != nil {
            predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate, request.predicate!])
        }
        
        request.predicate = predicate
        
        do {
            self.itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context, \(error)")
        }

        // reload our table
        self.tableView?.reloadData()
    }

    // Save our data in core data
    func saveData () {
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }

        // reload our table
        self.tableView?.reloadData()
    }
}

//MARK: - Utility functions
extension TodoListViewController {
    // Add an item to our local array if the string passed in isn't empty
    func addItem (_ title: String, _ isDone: Bool = false) -> Bool {
        if title.isEmpty {
            return false
        }

        self.itemArray.append(self.createItem(title))
        return true
    }

    // Create an Item
    func createItem (_ title: String, _ isDone: Bool = false) -> Item {
        let item = Item(context: self.context)
        item.title = title
        item.isDone = isDone
        item.parentCategory = self.selectedCategory
        return item
    }
}

//MARK: - UI Search Bar functionality
extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked (_ searchBar: UISearchBar) {
        // Set up our request
        let request: NSFetchRequest<Item> = Item.fetchRequest()

        // Set up our request predicate
        // Look for items where title contains 'what the user typed in'
        // [c] means case insensitive, [d] means diacritic insensitive (character signs or accents, etc)
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)

        // Set up our sorting criteria
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        retrieveData(with: request)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            retrieveData()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
