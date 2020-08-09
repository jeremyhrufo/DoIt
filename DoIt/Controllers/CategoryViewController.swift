//
//  CategoryViewController.swift
//  DoIt
//
//  Created by Jeremy Rufo on 8/9/20.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    //MARK: - Members
    var categories: [Category] = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    //MARK: - Normal functionality
    override func viewDidLoad () {
        super.viewDidLoad()
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
            if let text = alert.textFields?.first?.text {
                if self.addCategory(text) {
                    self.saveData()
                }
            }
        }))

        present(alert, animated: true, completion: nil)
    }
}

//MARK: - Tableview Datasource Methods
extension CategoryViewController {
    override func tableView (_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }

    override func tableView (_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get the reusable cell
        let cell = tableView.dequeueReusableCell(withIdentifier: K.categoryReusableCellName, for: indexPath)
        let category = self.categories[indexPath.row]

        // Set default label and accessory and return the cell
        cell.textLabel?.text = "(\(category.items?.count ?? 0)) " + "\(category.name ?? "<No Name>")"
        return cell
    }
}

//MARK: - Tableview Delegate Methods
extension CategoryViewController {
    override func tableView (_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Navigate to the View Controller
        self.performSegue(withIdentifier: K.goToItemsSegue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Set up our destination view controller for the items that belong to our selected category
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }
}

//MARK: - Storage functions
extension CategoryViewController {
    // Retrieve our data with passed in NSFetchRequest
    func retrieveData (with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            self.categories = try context.fetch(request)
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
extension CategoryViewController {
    // Add a category to our local array if the string passed in isn't empty
    func addCategory (_ name: String) -> Bool {
        if name.isEmpty {
            return false
        }

        self.categories.append(self.createCategory(name))
        return true
    }

    // Create a Category
    func createCategory (_ name: String) -> Category {
        let category = Category(context: self.context)
        category.name = name
        return category
    }
}
