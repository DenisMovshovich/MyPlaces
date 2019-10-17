//
//  MapManager.swift
//  MyPlaces
//
//  Created by Denis Movshovich on 16/10/2019.
//  Copyright © 2019 Denis Movshovich. All rights reserved.
//

import UIKit
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager()
    private var placeCoordinate: CLLocationCoordinate2D?
    private let regionInMeters = 1000.00
    private var directionsArray: [MKDirections] = []
    
    // Функция для отображения маркера на карте
    func setupPlacemark(place: Place, mapView: MKMapView) {
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
            annotation.title = place.name
            annotation.subtitle = place.type
            
            // Привязка созданной аннотации к конкретной точке на карте
            guard let placemarkLocation = placemark?.location else { return }
            // Если получилось определить местоположение маркера, то привязываем аннотацию к этой же точке на карте
            annotation.coordinate = placemarkLocation.coordinate
            // Передаем координаты нашей аннотации заведению
            self.placeCoordinate = placemarkLocation.coordinate
            // Задаем видимую область карты, чтобы на ней были видны все созданные аннотации
            mapView.showAnnotations([annotation], animated: true)
            // Чтобы выделить созданную аннотацию...
            mapView.selectAnnotation(annotation, animated: true)
            
        }
    }
    
    // Здесь проверяем включена ли у нас служба геолокации
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAutorization(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Your Location is not Available",
                    message: "To give permission Go to: Setting -> MyPlaces -> Location")
            }
        }
    }
    
    // Проверяем статус на разрешение использования геопозиции
    func checkLocationAutorization(mapView: MKMapView, segueIdentifier: String) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse: // Приложение разрешено определять геолокацию во время его использования
            mapView.showsUserLocation = true
            if segueIdentifier == "getAddress" { showUserLocation(mapView: mapView) }
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
    
    // Фокус карты на местоположении пользователя
    func showUserLocation(mapView: MKMapView) {
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    // Метод для прокладки маршрута
    func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> ()) {
        
        //определяем местоположение
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        
        // Включаем постоянное отслеживание текущего местоположения пользователя после того, как убедимся, что текущее местопложение определено выше
        locationManager.startUpdatingLocation()
        // инициаизируем текущее местоложение пользователя
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        // Выполняем запрос на прокладку маршрута
        guard let request = createDerectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        
        // Создаем маршрут на основе того, что у нас имеется в request
        let directions = MKDirections(request: request)
        // перед тем, как создать текущий маршрут, избавляемся от текущих маршрутов
        resetMapView(withNew: directions, mapView: mapView)
        
        // calculate занимается расчетом маршрута и возвращает расчитанный маршрут со всеми данными
        directions.calculate { (response, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            // вытаскиваем обработанный маршрут
            guard let response = response else {
                self.showAlert(title: "Error", message: "Directions is not available")
                return
            }
            
            for route in response.routes {
                mapView.addOverlay(route.polyline)
                // Отображаем весь маршрут на экране целиком
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                // Определяем расстояние(определяется в метрах, поэтому делим на 1000 и округляем до десятых)
                let distance = String(format: "%.1f", route.distance / 1000)
                // определяем время в пути
                let timeInterval = String(format: "%.1f", route.expectedTravelTime / 60)
                
                print("Расстояние до места: \(distance) км.")
                print("Время в пути составит: \(timeInterval) мин.")
            }
        }
    }
    
    //Метод для настрйоки запроса для построения маршрута
    func createDerectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        guard let destinationCoordinate = placeCoordinate else { return nil }
        // Определяем местоположение точки для начала маршрута
        let startingLocation = MKPlacemark(coordinate: coordinate)
        // Определяем местоположение пункта назначения
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        // Создаем запрос на постарение маршрута
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    // Отслеживание текущего местоположение пользователя
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        // Проверка на nil
        guard let location = location else { return }
        // Присваиваем свойству center значение, которое возвращает метод getCenterLocation(теперь у нас есть координаты центра отображаемой области)
        let center = getCenterLocation(for: mapView)
        // определяем расстояние до центра отображаемой области от координат предыдущего местоположения пользователя
        guard center.distance(from: location) > 50 else { return }
        
        closure(center)
       
    }
    
    // Метод для сброса старых маршрутов перед построением новых
    func resetMapView(withNew directions: MKDirections, mapView: MKMapView) {
        // Удаляем с карты наложение текущего маршрута
        mapView.removeOverlays(mapView.overlays)
        // Добавляем в массив текущие маршруты
        directionsArray.append(directions)
        // Перебираем каждый элемент из массива directionsArray и отменяем у них маршрут
        let _ = directionsArray.map { $0.cancel() }
        // Удаляем все элементы из массива
        directionsArray.removeAll()
    }
    
    // Метод для определения координат в центре экрана
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        // Возвращаем широту и долготу
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        
        // Создаем объект UIWindow
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        // Инициализируем свойство rootViewController у UIWindow
        alertWindow.rootViewController = UIViewController()
        // Определяем позиционирование alertWindow относительно других окон(поверх)
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        // Делаем окно ключевым и видимым
        alertWindow.makeKeyAndVisible()
        // Теперь мы можем вызвать метод present у свойства rootViewController
        alertWindow.rootViewController?.present(alert, animated: true)
        
    }

}


