//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Denis Movshovich on 01/07/2019.
//  Copyright © 2019 Denis Movshovich. All rights reserved.
//

import UIKit

class NewPlaceViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Скрываем лишние сепараторы
        tableView.tableFooterView = UIView()
  
    }
    
    // MARK: Table view Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
        } else {
            view.endEditing(true)
        }
    }
}

// MARK: Text field Delegate

extension NewPlaceViewController: UITextFieldDelegate {

    // Скрываем клавиатуру по нажатию на Done

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
