//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Denis Movshovich on 28/08/2019.
//  Copyright © 2019 Denis Movshovich. All rights reserved.


// UIKit :)
import UIKit
// Для работы с картами
import MapKit
// для работы с местоположением пользователя
import CoreLocation

class MapViewController: UIViewController {

    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    // Отвечает за настройку и управление службами геолокации
    let locationManager = CLLocationManager()
    let regionInMeters = 10_000.00
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Назначаем наш класс делегатом ответсвенным за выполнение методов протокола MKMapViewDelegate
        mapView.delegate = self
        setupPlacemark()
        checkLocationServices()
    }
    

    // Центрирование View по геолокации
    
    @IBAction func centerViewInUserLocation() {
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                               latitudinalMeters: regionInMeters,
                               longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
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
            // Если ошибки нет, то извлекаю опционал из объекта placemarks
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
    
    // Здесь проверяем включена ли у нас служба геолокации
    private func checkLocationServices() {
        
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAutorization()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Your Location is not Available",
                    message: "To give permission Go to: Setting -> MyPlaces -> Location")
            }
        }
    }
    
    // делаем первоначальные установки свойства locationManager
    private func setupLocationManager() {
        locationManager.delegate = self
        // Точность определения местоположения пользователя
         locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // Проверяем статус на разрешение использования геопозиции
    private func checkLocationAutorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse: // Приложение разрешено определять геолокацию во время его использования
            mapView.showsUserLocation = true
            break
        case .denied: // Приложению отказано использовать службы геолокации или она отключена
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Your Location is not Available",
                    message: "To give permission Go to: Setting -> MyPlaces -> Location"
                )
            }
            break
        case .notDetermined: // Статус неопределен. Запрашиваем разрешение на авторизацию приложения для использвания геолокации
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted:
            break // когда приложение не авторизовано для использования служб геолокации
            // Show alert controller
        case .authorizedAlways: // когда приложению разрешено использовать службы геолокации постоянно
            break
        @unknown default:
            print("New case is available")
        }
    }
    
    private func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        present(alert, animated: true)
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

// Расширение для отслеживания местоположения в реальном времени
extension MapViewController: CLLocationManagerDelegate {
    // Данный метод вызывается при каждом изменении статуса авторизации нашего приложения для использования служб геолокации
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAutorization()
    }
}
