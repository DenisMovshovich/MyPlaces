//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Denis Movshovich on 24/06/2019.
//  Copyright © 2019 Denis Movshovich. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var reversedSortingButton: UIBarButtonItem!
    
    var places: Results<Place>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        places = realm.objects(Place.self)
        
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 : places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        let place = places[indexPath.row]
        
        cell.nameLabel?.text = place.name
        cell.locationLabel?.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        
        
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        cell.imageOfPlace.clipsToBounds = true
        
        return cell
    }
    
    // MARK: Table View Delegate
    
    // Метод, который возвращает и исполняет те или иные действия с ячейкой
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let place = places[indexPath.row]
        // создаем объект класса, которые выполняет действия с ячейкой
        let deleteAction = UITableViewRowAction(style: .default, title: "Нахуй с пляжа") { (_, _) in
            // Удаление объекта из DB
            StorageManager.deleteObject(place: place)
            // Удаление объекта из списка на главном экране 
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        return [deleteAction]
    }
    
    
    
    
     // MARK: - Navigation
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Реализация перехода и отображения на экране данных о заведении из выбранной ячейки
        if segue.identifier == "showDetail" {
            // находим индекс выбранной ячейки
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            // имея индекс извлекаем объект выбранной ячейки
            let place = places[indexPath.row]
            // создаем экземпляр NewPlaceViewController
            let newPlaceVC = segue.destination as! NewPlaceViewController
            // Присваиваем данные выбранного заведения
            newPlaceVC.currentPlace = place
            
        }
    
     }
 
    
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        
        newPlaceVC.savePlace()
        tableView.reloadData()
    }
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
    }
    
    @IBAction func reversedSorting(_ sender: Any) {
    }
    
}
