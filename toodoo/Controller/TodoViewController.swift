//
//  ViewController.swift
//  toodoo
//
//  Created by Lucy Wang on 6/26/18.
//  Copyright © 2018 Lucy Wang. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoViewController: SwipeTableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    var items : Results<Item>?
    let realm = try! Realm()
    var category : Category? {
        // didSet triggered when category is set
        didSet {
            load()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = category?.name
        guard let color = category?.color else { fatalError() }
        updateNavbar(withHexString: color)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavbar(withHexString: "1D9BF6")
    }
    
    func updateNavbar(withHexString color: String) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist")
        }
        guard let navbarColor = UIColor(hexString: color) else { fatalError() }
        navBar.barTintColor = navbarColor
        navBar.tintColor = ContrastColorOf(navbarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : navBar.tintColor]
        searchBar.barTintColor = navbarColor
    }
    
    // MARK: Table view methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = items?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
//            if let
//                color = FlatWhite().darken(byPercentage: CGFloat(indexPath.row)/CGFloat(items!.count)) {
            cell.backgroundColor = UIColor(hexString: category!.color!)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(items!.count))
            cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
//            }
        } else {
            cell.textLabel?.text = "No items added"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        items![indexPath.row].done = items![indexPath.row].done
        
        if let item = items?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving status, \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Add items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todo Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // once user clicks add item button
            do {
                try self.realm.write {
                    if let currentCategory = self.category {
                        let item = Item()
                        item.title = textField.text!
                        item.dateCreated = Date()
                        item.color = UIColor.randomFlat.hexValue()
                        currentCategory.items.append(item)
                        self.tableView.reloadData()
                    }
                }
            } catch {
                print("Error saving new items \(error)")
            }
        }
    
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)

        present(alert, animated: true, completion: nil)
    }
    
    func load() {
        items = category?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    override func update(at indexPath: IndexPath) {
        if let item = self.items?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(item)
                }
            } catch {
                print("Error deleting item \(error)")
            }
        }
    }
}

// MARK: Search bar methods
extension TodoViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        items = items?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            load()
            DispatchQueue.main.async { //manages processes to different threads
                searchBar.resignFirstResponder()
            }
        }
    }
}







