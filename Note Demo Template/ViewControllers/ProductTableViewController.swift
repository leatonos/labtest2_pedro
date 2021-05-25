//
//  ProductTableViewController.swift
//  Note Demo Template
//
//  Created by user198868 on 5/24/21.
//  Copyright © 2021 mohammadkiani. All rights reserved.
//

import UIKit
import CoreData

class ProductTableViewController: UITableViewController {
    
    @IBOutlet weak var trashBtn: UIBarButtonItem!
    
    var deletingMovingOption: Bool = false
    
    var products = [Product]()
    var selectedProvider: Provider?{
        
        didSet{
            loadProducts()
        }
        
    }
    
    var editMode: Bool = false
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = selectedProvider?.name
        showSearchBar()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return products.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)

        // Configure the cell...
        
        let product = products[indexPath.row]
        
        cell.textLabel?.text = product.name
        cell.textLabel?.backgroundColor = .darkGray
        cell.textLabel?.textColor = .white

        let backgroundView = UIView()
        backgroundView.backgroundColor = .lightGray
        cell.selectedBackgroundView = backgroundView
        
        
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteProduct(product: products[indexPath.row])
            saveProducts()
            products.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? ProductViewController{
            destination.delegate = self
            
            if let cell = sender as? UITableViewCell {
                if let index = tableView.indexPath(for: cell)?.row {
                    destination.selectedProduct = products[index]
                }
            }
        }
        
        
    }
    
    @IBAction func unwindToProducTableViewController(_ unwindSegue: UIStoryboardSegue) {
//        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
        saveProducts()
        loadProducts()
        tableView.setEditing(false, animated: true)
    }
    
    //MARK: - Action Methods
    
    
    
    //MARK: - Trash Button
    @IBAction func trashBtnPressed(_ sender: UIBarButtonItem) {
        if let indexPaths = tableView.indexPathsForSelectedRows {
            let rows = (indexPaths.map {$0.row}).sorted(by: >)
            
            let _ = rows.map {deleteProduct(product: products[$0])}
            let _ = rows.map {products.remove(at: $0)}
            
            tableView.reloadData()
            saveProducts()
            
        }
    }
    //MARK: - Edit Button
    
    @IBAction func editModePressed(_ sender: UIBarButtonItem) {
        
        deletingMovingOption = !deletingMovingOption
        
        trashBtn.isEnabled = !trashBtn.isEnabled
        
        tableView.setEditing(deletingMovingOption, animated: true)
        
    }
    
    //MARK: - show search bar func
    func showSearchBar() {
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Product"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.searchTextField.textColor = .lightGray
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard identifier != "moveNoteSegue" else {
            return true
        }
        return editMode ? false : true
    }
    
    
       
    // MARK: - Core data interactions

    func loadProducts(predicate: NSPredicate? = nil){
        
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        let providerPredicate = NSPredicate(format: "parentProvider.name=%@", selectedProvider!.name!)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [providerPredicate, additionalPredicate])
        } else {
            request.predicate = providerPredicate
        }
        
        do {
            products = try context.fetch(request)
        } catch {
            print("Error loading products \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    func deleteProduct(product:Product){
        context.delete(product)
    }
    
    func updateProduct(with name:String,with id:String,with desc:String, with price:String){
        products = []
        let newProduct = Product(context: context)
        newProduct.name = name
        newProduct.desc = desc
        newProduct.id = id
        newProduct.price = price
        newProduct.parentProvider = selectedProvider
        saveProducts()
        loadProducts()
    }
    
    
    func saveProducts(){
        
        do {
            try context.save()
            tableView.reloadData()
        } catch {
            print("Error saving the product \(error.localizedDescription)")
        }
    }
    
}

//MARK: - search bar delegate methods
extension ProductTableViewController: UISearchBarDelegate {
    
    
    /// search button on keypad functionality
    /// - Parameter searchBar: search bar is passed to this function
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // add predicate
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        loadProducts(predicate: predicate)
    }
    
    
    /// when the text in text bar is changed
    /// - Parameters:
    ///   - searchBar: search bar is passed to this function
    ///   - searchText: the text that is written in the search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadProducts()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}
