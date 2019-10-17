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
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var places: Results<Place>!
    private var filteredPlaces: Results<Place>!
    private var ascendingSorting = true
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    @IBOutlet var reversedSortingButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        places = realm.objects(Place.self)
        
        // Настройка search Contoller
        
        // Назначенм наш класс получателем информации об изменении текста в строке поиска
        searchController.searchResultsUpdater = self
        // Разрешаем взаимодействие с результатом поиска
        searchController.obscuresBackgroundDuringPresentation = false
        // Название строки поиска
        searchController.searchBar.placeholder = "Search"
        // Прикрепляем search Controller в Navigation Bar
        navigationItem.searchController = searchController
        // Скрываем строку поиска при переходе на другой экран
        definesPresentationContext = true
        
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering {
            return filteredPlaces.count
        }
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
        
//        var place = Place()
        
//        if isFiltering {
//            place = filteredPlaces[indexPath.row]
//        } else {
//            place = places[indexPath.row]
//        }
        
        cell.nameLabel?.text = place.name
        cell.locationLabel?.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        cell.cosmosView.rating = place.rating

        return cell
    }
    
    // MARK: Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Метод, который возвращает и исполняет те или иные действия с ячейкой
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let place = places[indexPath.row]
        // создаем объект класса, которые выполняет действия с ячейкой
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (_, _) in
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
            // имея индекс извлекаем объект выбранной ячейки, проверяя активна ли строка поиска
            let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
//            let place: Place
//            if isFiltering {
//                place = filteredPlaces[indexPath.row]
//            } else {
//                place = places[indexPath.row]
//            }
            
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
        
        sorting()
    }
    
    @IBAction func reversedSorting(_ sender: Any) {
        
        ascendingSorting.toggle() // Меняем значение на противоположное
        // Меняем изображение кнопки
        if ascendingSorting {
            reversedSortingButton.image = #imageLiteral(resourceName: "AZ")
        } else {
            reversedSortingButton.image = #imageLiteral(resourceName: "ZA")
        }
        
        sorting()
    }
    // Метод для сортировки ячеек
    private func sorting() {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        
        tableView.reloadData()
    }
}

extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        
        tableView.reloadData()
    }
}
