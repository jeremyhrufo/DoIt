//
//  ViewController.swift
//  DoIt
//
//  Created by Jeremy Rufo
//  Copyright © 2020 JRufo, LLC. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {
    //MARK: - Members
    let realm = try! Realm()
    var doItItems: Results<Item>?
    var selectedCategory: Category? {
        didSet { // Once 'selectedCategory' is set with a value, retrieve our data
            retrieveData()
            title = selectedCategory?.name
        }
    }

    //MARK: - Normal functionality
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
                if let category = self.selectedCategory {
                    do {
                        try self.realm.write {
                            category.items.append(Item(title: text))
                        }
                    } catch {
                        print("Error adding  item to realm, \(error)")
                    }
                }
                self.reloadTable()
            }
        }))

        present(alert, animated: true, completion: nil)
    }
}

//MARK: - Tableview Datasource Methods
extension TodoListViewController {
    override func tableView (_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.doItItems?.count ?? 1
    }

    override func tableView (_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get the reusable cell
        let cell = tableView.dequeueReusableCell(withIdentifier: K.itemReusableCellName, for: indexPath)

        if let item = self.doItItems?[indexPath.row] {
            // Set default label and accessory and return the cell
            cell.textLabel?.text = item.title
            cell.accessoryType = item.isDone ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }

        return cell
    }
}

//MARK: - TableView Delegate methods
extension TodoListViewController {
    override func tableView (_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Unselect our row; get item and reverse isDone flag; save and reload the table
        tableView.deselectRow(at: indexPath, animated: false)

        // Update our realm object
        if let item = doItItems?[indexPath.row] {
            do {
                try realm.write {
                    // Delete
                    //realm.delete(item)
                    // Update isDone (instead of deleting)
                    item.isDone = !item.isDone
                }
            } catch {
                print("Error updating item in realm, \(error)")
            }
        }
        self.reloadTable()
    }
}

//MARK: - Storage functions
extension TodoListViewController {
    func retrieveData() {
        doItItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        self.reloadTable()
    }

    // Save our data in core data
    func saveData (item: Item) {
        do {
            try realm.write {
                realm.add(item)
            }
        } catch {
            print("Error saving item to realm, \(error)")
        }

        self.reloadTable()
    }
}

//MARK: - Utility functions
extension TodoListViewController {
    func reloadTable() {
        self.tableView.reloadData()
    }
}

//MARK: - UI Search Bar functionality
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked (_ searchBar: UISearchBar) {
        doItItems = doItItems?.filter("title CONTAINS[cd] %@", searchBar.text!)
            .sorted(byKeyPath: "dateCreated", ascending: true)
        self.reloadTable()
    }

    func searchBar (_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            retrieveData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
