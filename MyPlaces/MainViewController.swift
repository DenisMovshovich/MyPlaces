//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Denis Movshovich on 24/06/2019.
//  Copyright © 2019 Denis Movshovich. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    
    let restauranNames = ["Burger King", "McDonalds", "Cinema 5", "Джалиль", "Sushi House", "Пепперони", "TOP HOP"]

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restauranNames.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.textLabel?.text = restauranNames[indexPath.row]
        cell.imageView?.image = UIImage(named: restauranNames[indexPath.row])

        return cell
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
