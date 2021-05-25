//
//  ProviderTableViewController.swift
//  Note Demo Template
//
//  Created by user198868 on 5/23/21.
//  Copyright © 2021 mohammadkiani. All rights reserved.
//

import UIKit
import CoreData

class ProviderTableViewController: UITableViewController {

    //Create a provider
    
    var providers = [Provider]()
    var products = [Product]()
    
    
    var selectedOption = "Products"
    
    //Create context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if(selectedOption == "Products"){
            loadAllProducts()
            navigationItem.title = "Products"
        }else{
            loadProviders()
            navigationItem.title = "Providers"
        }
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    
    // This code refresh the table everytime we get to this screen again
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var numberOfRows:Int?
        if(selectedOption == "Products"){
            numberOfRows = products.count
        }else{
            numberOfRows = providers.count
        }
        return numberOfRows!
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProviderCell", for: indexPath)

        if(selectedOption == "Products"){
            cell.textLabel?.text = products[indexPath.row].name
            cell.textLabel?.textColor = .lightGray
            cell.detailTextLabel?.text = ""
            cell.imageView?.image = nil
        }else{
            cell.textLabel?.text = providers[indexPath.row].name
            cell.textLabel?.textColor = .lightGray
            cell.detailTextLabel?.text = "\(providers[indexPath.row].products?.count ?? 0)"
            cell.imageView?.image = UIImage(systemName: "folder")
        }
        // Configure the cell...
        
        

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
            if selectedOption == "Products"{
                
                deleteProduct(product: products[indexPath.row])
                saveProducts()
                products.remove(at: indexPath.row)
                // Delete the row from the data source
                tableView.deleteRows(at: [indexPath], with: .fade)
                
            }else{
                
                deleteProvider(provider: providers[indexPath.row])
                saveProviders()
                providers.remove(at: indexPath.row)
                // Delete the row from the data source
                tableView.deleteRows(at: [indexPath], with: .fade)
                
            }
            
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if( selectedOption == "Products"){
            performSegue(withIdentifier: "fromProductsToProduct", sender: self)
        }else{
            performSegue(withIdentifier: "fromProvidersToProducts", sender: self)
            
        }
        
    }
    
    // MARK: - Navigation

    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if( segue.identifier == "fromProductsToProduct"){
            
            flag.origin = "Provider"
            
            if let destination = segue.destination as? ProductViewController{
                destination.delegateb = self
                
                if let indexPath = tableView.indexPathForSelectedRow{
                    destination.selectedProduct = products[indexPath.row]
                }
            }
            
        }else{
            
            flag.origin = "not Provider"
            
            let destination = segue.destination as! ProductTableViewController
            if let indexPath = tableView.indexPathForSelectedRow{
                destination.selectedProvider = providers[indexPath.row]
            }
        }
        
    }
    

    // MARK: - Buttons
    
    @IBAction func addProvider(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Provider", message: "Please insert the provider name", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { action in
            
            let folderNames = self.providers.map {$0.name?.lowercased()}
            guard !folderNames.contains(textField.text?.lowercased()) else {self.showAlert();return}
            
            let newProvider = Provider(context: self.context)
            newProvider.name = textField.text!
            self.providers.append(newProvider)
            self.saveProviders()
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.orange, forKey: "titleTextColor")
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        alert.addTextField{field in
            textField = field
            textField.placeholder = "provider name"
        }
        
        present(alert,animated: true, completion: nil)
        
    }
    
    func showAlert(){
        let alert = UIAlertController(title:"Name is taken", message: "please choose another name", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "ok", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Switch
    
    @IBAction func Switch(_ sender: UIBarButtonItem) {
        //sender.title = "help"
        
        if selectedOption == "Products"{
            selectedOption = "Providers"
            loadProviders()
            sender.title = "Switch to Products"
        }else{
            selectedOption = "Products"
            loadAllProducts()
            sender.title = "Switch to Providers"
        }
        
    }
    
    
    //MARK: - core data interaction methods
    
    /// load providers from core data
    func loadProviders() {
        let request: NSFetchRequest<Provider> = Provider.fetchRequest()
        
        do {
            providers = try context.fetch(request)
        } catch {
            print("Error loading providers \(error.localizedDescription)")
        }
        tableView.reloadData()
        navigationItem.title = "Providers"
    }
    
    func loadAllProducts(){
        
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        
        do {
            products = try context.fetch(request)
        } catch {
            print("Error loading Products \(error.localizedDescription)")
        }
        tableView.reloadData()
        navigationItem.title = "Products"
    }
    
    /// save providers into core data
    func saveProviders() {
        do {
            try context.save()
            tableView.reloadData()
        } catch {
            print("Error saving the provider \(error.localizedDescription)")
        }
    }
    
    func deleteProvider(provider: Provider) {
        context.delete(provider)
    }
    
    func saveProducts() {
        do {
            try context.save()
            tableView.reloadData()
        } catch {
            print("Error saving the provider \(error.localizedDescription)")
        }
    }
    
    func deleteProduct(product: Product) {
        context.delete(product)
    }
    
    func updateProduct(with name:String,with id:String,with desc:String, with price:String){
        products = []
        let newProduct = Product(context: context)
        newProduct.name = name
        newProduct.desc = desc
        newProduct.id = id
        newProduct.price = price
        //newProduct.parentProvider = providers[]
        saveProducts()
        loadAllProducts()
    }
    
    
}
