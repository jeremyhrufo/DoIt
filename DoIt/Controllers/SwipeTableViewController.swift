//
//  SwipeTableViewController.swift
//  DoIt
//
//  Created by Jeremy Rufo on 8/11/20.
//  Copyright © 2020 JRufo, LLC. All rights reserved.
//

import UIKit
import SwipeCellKit

protocol SwipeTableViewControllerProtocol {
    func deleteCell(indexPath: IndexPath)
}

typealias SwipeTableController = SwipeTableViewController & SwipeTableViewControllerProtocol

class SwipeTableViewController:
    UITableViewController,
    SwipeTableViewCellDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 70
        tableView.separatorStyle = .none
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        guard let controller = self as? SwipeTableController else {
            return nil
        }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            controller.deleteCell(indexPath: indexPath)
        }

        // customize the action appearance
        deleteAction.image = UIImage(systemName: "trash.fill")

        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
    //MARK: - Table View Data Source
    override func tableView (_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.reusableCellName, for: indexPath) as! SwipeTableViewCell
        cell.delegate = self

        return cell
    }
    
    //MARK: - Other functions
    func reloadTable() {
        tableView.reloadData()
    }
}
