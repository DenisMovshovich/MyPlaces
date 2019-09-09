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
    let annotationIdentifier = "annotationIdentifier"
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Назначаем наш класс делегатом ответсвенным за выполнение методов протокола MKMapViewDelegate
        mapView.delegate = self
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

// MKMapViewDelegate содержит методы для более тонкой работы с картами

extension MapViewController: MKMapViewDelegate {
    
    // Данный метод отвечает за отображение аннотации
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Надо убедиться, что данный объект не является аннотацией текущего метоположения пользователя
        // Если маркером на карте является текущее местоположение пользователя, то выходим из метода
        guard !(annotation is MKUserLocation) else { return nil }
        // Создаем объект класса MKAnnotationView, который и представляет аннотацию на карте
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        
        // В том случае, если на карте не окажется ни одного представления с аннотацией, которое мы могли бы переиспользовать
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            // Отображаем аннотацию в виде баннера
            annotationView?.canShowCallout = true
        }
        // Проверяем изображение (place.imageData) на nil
        if let imageData = place.imageData {
            // Свойство для отображения изображения.
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            // Настройка изображения
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView 
        }
        // Возвращаем этот объект
        return annotationView
    }
}
