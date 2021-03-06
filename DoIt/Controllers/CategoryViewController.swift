//
//  CategoryViewController.swift
//  DoIt
//
//  Created by Jeremy Rufo on 8/9/20.
//  Copyright © 2020 JRufo, LLC. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableController {
    //MARK: - Members
    let realm = try! Realm()
    var categories: Results<Category>?

    //MARK: - Normal functionality
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retrieveData()

        guard let navBar = navigationController?.navigationBar else { fatalError("Nav controller is nil") }
        if let barColor = UIColor(hexString: "1D9BF6") {
            navBar.barTintColor = barColor
            navBar.backgroundColor = barColor

            let contrastColor = ContrastColorOf(barColor, returnFlat: true)
            navBar.tintColor = contrastColor
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: contrastColor]
        }
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
                self.save(category: Category(with: name, and: UIColor.randomFlat().hexValue()))
            }
        }))

        present(alert, animated: true, completion: nil)
    }
}

//MARK: - Tableview Datasource Methods
extension CategoryViewController {
    override func tableView (_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }

    override func tableView (_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = "(\(category.items.count)) " + "\(category.name)"
            if let color = UIColor(hexString: category.colorHexString) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
        } else {
            cell.textLabel?.text = "No Categories Added Yet"
        }

        return cell
    }
}

//MARK: - Tableview Delegate Methods
extension CategoryViewController {
    override func tableView (_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Navigate to the View Controller
        performSegue(withIdentifier: K.goToItemsSegue, sender: self)
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
        reloadTable()
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
            reloadTable()
        }
    }
}

//MARK: - SwipeTableViewController Protocol
extension CategoryViewController {
    func deleteCell(indexPath: IndexPath) {
        if let item = categories?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch {
                print("Error deleting category in realm, \(error)")
            }
        }
    }
}
