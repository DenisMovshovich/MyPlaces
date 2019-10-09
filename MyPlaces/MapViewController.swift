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

// Данные протокол использован для передачи адреса из выбранного на карте в поле placeLocation в NewPlaceViewController
protocol MapViewControllerDelegate {
    // Метод для захвата адреса
    func getAddress(_ address: String?)
}

class MapViewController: UIViewController {
    
    // Делегат класса MapViewController
    var MapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    // Отвечает за настройку и управление службами геолокации
    let locationManager = CLLocationManager()
    let regionInMeters = 1000.00
    var incomeSegueIdentifier = ""
    var placeCoordinate: CLLocationCoordinate2D?
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var mapPinImage: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var goButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Назначаем наш класс делегатом ответсвенным за выполнение методов протокола MKMapViewDelegate
        mapView.delegate = self
        setupMapView()
        checkLocationServices()
        addressLabel.text = ""
    }
    
    
    // Центрирование View по геолокации
    
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    @IBAction func centerViewInUserLocation() {
        showUserLocation()
    }
    
    @IBAction func doneButtonPressed() {
        // Захват адреса изи addressLabel для передачи в NewPlaceNewController
        MapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
        
    }
    
    @IBAction func goButtonPressed() {
        
        getDirections()
        
    }
    
    private func setupMapView() {
        
        goButton.isHidden = true
        
        if incomeSegueIdentifier == "showPlace" {
            setupPlacemark()
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
            
        }
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
            // Передаем координаты нашей аннотации заведению
            self.placeCoordinate = placemarkLocation.coordinate
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
            if incomeSegueIdentifier == "getAddress" { showUserLocation() }
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
    
    private func showUserLocation() {
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
        
    }
    
    // Метод для прокладки маршрута
    private func getDirections() {
        
        //определяем местоположение
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        
        // Выполняем запрос на прокладку маршрута
        guard let request = createDerectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        
        // Создаем маршрут на основе того, что у нас имеется в request
        let directions = MKDirections(request: request)
        
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
                self.mapView.addOverlay(route.polyline)
                // Отображаем весь маршрут на экране целиком
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
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
    private func createDerectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
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
    
    
    // Метод для определения координат в центре экрана
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        // Возвращаем широту и долготу
        return CLLocation(latitude: latitude, longitude: longitude)
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
    
    // Данные метод будет вызываться каждый раз при смене отображаемого на экране региона
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // Получаем координаты из метода getCenterLocation
        let center = getCenterLocation(for: mapView)
        // CLGeocoder отвечает за преобразование географических координат и географических названий
        let geocoder = CLGeocoder()
        // geocodeAddressString позволяет определить местоположение на карте по параметру переданнному в этот метод(в данном случае по location). complitionHandler возвращает массив меток, соответствующих переданному адресу.
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            // Если процесс проходит успешно то объект error возвращает nil
            if let error = error {
                print(error)
                return
            }
            // Если ошибки нет, то извлекаю опционал из объекта placemarks
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            // Получаем название улицы
            let streetName = placemark?.thoroughfare
            // Затем номер дома
            let buildNumber = placemark?.subThoroughfare
            // Для асинхронного обновления интерфейса в основном потоке
            DispatchQueue.main.async {
                // Проверка на nil
                if streetName != nil && buildNumber != nil {
                    self.addressLabel.text = "\(streetName!),  \(buildNumber!)"
                } else if streetName != nil {
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
            }
        }
    }
    
    // Создаем линию по наложению маршрута, чтобы сделать его видимым
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .green
        return renderer
    }
}

// Расширение для отслеживания местоположения в реальном времени
extension MapViewController: CLLocationManagerDelegate {
    // Данный метод вызывается при каждом изменении статуса авторизации нашего приложения для использования служб геолокации
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAutorization()
    }
}
