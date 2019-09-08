//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Denis Movshovich on 28/08/2019.
//  Copyright © 2019 Denis Movshovich. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    var place: Place!
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlacemark()

    }
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    // Функция для оторажения маркера на карте
    private func setupPlacemark() {
        // Извлекаем адрес заведения
        guard let location = place.location else { return }
        // CLGeocoder отвечает за преобразование географических координат и географических названий
        let geocoder = CLGeocoder()
        // geocodeAddressString позволяет определить местоположение на карте по параметру переданнному в этот метод(в данном случае по location). complitionHandler возвращает массив меток, соответствующих переданному адресу.
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            // Если процесс проходит успешно то объект error возвращает nil
            if let error = error {
                print(error)
                return
            }
            // Если ошибки нет, то извелекаю опционал из объекта placemarks
            guard let placemarks = placemarks else { return }
            // Так как, мы ищем местопложение по конкретному адресу, то массив placemarks должен создержать всего одну метку("первый элемент")
            let placemark = placemarks.first
            // Объект annotation используется для описания точки на карте
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            // Привязка созданной аннотации к конкретной точке на карте
            guard let placemarkLocation = placemark?.location else { return }
            // Если получилось определить местоположение маркера, то привязываем аннотацию к этой же точке на карте
            annotation.coordinate = placemarkLocation.coordinate
            // Задаем видимую область карты, чтобы на ней были видны все созданные аннотации
            self.mapView.showAnnotations([annotation], animated: true)
            // Чтобы выделить созданную аннотацию...
            self.mapView.selectAnnotation(annotation, animated: true)
            
            
            
            
        }
    }
}
