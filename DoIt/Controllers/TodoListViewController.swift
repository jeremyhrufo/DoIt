//
//  ViewController.swift
//  DoIt
//
//  Created by Jeremy Rufo
//  Copyright © 2020 JRufo, LLC. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableController {
    //MARK: - Members
    let realm = try! Realm()
    var doItItems: Results<Item>?
    var selectedCategory: Category? {
        didSet { // Once 'selectedCategory' is set with a value, retrieve our data
            retrieveData()
        }
    }
    @IBOutlet weak var searchBar: UISearchBar!

    //MARK: - Normal functionality
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let navBar = navigationController?.navigationBar else { fatalError("Nav controller is nil") }
        if let colorHexString = selectedCategory?.colorHexString {
            if let barColor = UIColor(hexString: colorHexString) {
                navBar.barTintColor = barColor
                navBar.backgroundColor = barColor
                searchBar.barTintColor = barColor

                let contrastColor = ContrastColorOf(barColor, returnFlat: true)
                navBar.tintColor = contrastColor
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: contrastColor]
            }
            title = selectedCategory!.name
        }
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
                if let category = self.selectedCategory {
                    do {
                        try self.realm.write {
                            category.items.append(Item(with: text))
                        }
                    } catch {
                        print("Error adding item to realm, \(error)")
                    }
                    self.reloadTable()
                }
            }
        }))

        present(alert, animated: true, completion: nil)
    }
}

//MARK: - Tableview Datasource Methods
extension TodoListViewController {
    override func tableView (_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return doItItems?.count ?? 1
    }

    override func tableView (_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if let item = doItItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.isDone ? .checkmark : .none

            // We will make our background be a gradient based on the category's color which we must already have
            let hexString = selectedCategory!.colorHexString
            if let color = UIColor(hexString: hexString) {
                cell.backgroundColor = color.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(doItItems!.count))
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
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
            reloadTable()
        }
    }
}

//MARK: - Storage functions
extension TodoListViewController {
    func retrieveData() {
        doItItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        reloadTable()
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
        reloadTable()
    }
}

//MARK: - SwipeTableViewController Protocol
extension TodoListViewController {
    func deleteCell(indexPath: IndexPath) {
        if let item = doItItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch {
                print("Error deleting item in realm, \(error)")
            }
        }
    }
}

//MARK: - UI Search Bar functionality
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked (_ searchBar: UISearchBar) {
        doItItems = doItItems?.filter("title CONTAINS[cd] %@", searchBar.text!)
            .sorted(byKeyPath: "dateCreated", ascending: true)
        reloadTable()
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
