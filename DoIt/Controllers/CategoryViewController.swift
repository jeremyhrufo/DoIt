//
//  CategoryViewController.swift
//  DoIt
//
//  Created by Jeremy Rufo on 8/9/20.
//  Copyright © 2020 JRufo, LLC. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: SwipeTableController {
    //MARK: - Members
    let realm = try! Realm()
    var categories: Results<Category>?

    //MARK: - Normal functionality
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retrieveData()
    }

    @IBAction func addButtonPressed (_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Category", message: nil, preferredStyle: .alert)

        // Add a cancel button
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        // Create a text field to be used to extend the scope of the alert text field
        alert.addTextField(configurationHandler: { alertTextField in
            alertTextField.placeholder = "Enter category name here..."
        })

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            // Grab the text out of the alert text field and save it
            if let name = alert.textFields?.first?.text {
                self.save(category: Category(with: name))
            }
        }))

        present(alert, animated: true, completion: nil)
    }
}

//MARK: - Tableview Datasource Methods
extension CategoryViewController {
    override func tableView (_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories?.count ?? 1
    }

    override func tableView (_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        let category = self.categories?[indexPath.row]

        // Set default label and accessory and return the cell
        cell.textLabel?.text = "(\(category?.items.count ?? 0)) " + "\(category?.name ?? "No Categories Added Yet")"

        return cell
    }
}

//MARK: - Tableview Delegate Methods
extension CategoryViewController {
    override func tableView (_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Navigate to the View Controller
        self.performSegue(withIdentifier: K.goToItemsSegue, sender: self)
    }

    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        // Set up our destination view controller for the items that belong to our selected category
        let destinationVC = segue.destination as! TodoListViewController

        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
}

//MARK: - Storage functions
extension CategoryViewController {
    func retrieveData() {
        categories = realm.objects(Category.self).sorted(byKeyPath: "dateCreated", ascending: true)
        self.reloadTable()
    }

    // Save our data in core data
    func save (category: Category?) {
        if let value = category {
            do {
                try realm.write {
                    realm.add(value)
                }
            } catch {
                print("Error saving category to realm, \(error)")
            }
            self.reloadTable()
        }
    }
}

//MARK: - SwipeTableViewController Protocol
extension CategoryViewController {
    func deleteCell(indexPath: IndexPath) {
        if let item = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(item)
                }
            } catch {
                print("Error deleting category in realm, \(error)")
            }
        }
    }
}

//MARK: - Utility functions
extension CategoryViewController {
    func reloadTable() {
        self.tableView.reloadData()
    }
}
