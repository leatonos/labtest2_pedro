//
//  ProductViewController.swift
//  Note Demo Template
//
//  Created by user198868 on 5/24/21.
//  Copyright © 2021 mohammadkiani. All rights reserved.
//

import UIKit

class ProductViewController: UIViewController {

    
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldID: UITextField!
    @IBOutlet weak var textFieldDesc: UITextField!
    @IBOutlet weak var textFieldPrice: UITextField!
    @IBOutlet weak var textFieldProvider: UITextField!
    
    
    var selectedProduct: Product? {
        didSet {
            editMode = true
        }
    }
    
    var editMode: Bool = false
    
    weak var delegate: ProductTableViewController?
    weak var delegateb: ProviderTableViewController?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textFieldName.text = selectedProduct?.name
        textFieldID.text = selectedProduct?.id
        textFieldDesc.text = selectedProduct?.desc
        textFieldPrice.text = selectedProduct?.price
        textFieldProvider.text = selectedProduct?.parentProvider?.name
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        guard textFieldName.text != "" else {return}
        
        if editMode {
        
            if flag.origin == "Provider"{
                delegateb!.deleteProduct(product: selectedProduct!)
                
                delegateb!.updateProduct(with: textFieldName.text!, with: textFieldID.text!, with: textFieldDesc.text!, with: textFieldPrice.text!)
            }else{
                
                delegate!.deleteProduct(product: selectedProduct!)
                
                delegate!.updateProduct(with: textFieldName.text!, with: textFieldID.text!, with: textFieldDesc.text!, with: textFieldPrice.text!)            }
            
        }
        
               
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
