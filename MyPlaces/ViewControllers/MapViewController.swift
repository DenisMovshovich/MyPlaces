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
    
    let mapManager = MapManager()
    // Делегат класса MapViewController
    var MapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    
    let annotationIdentifier = "annotationIdentifier"
    // Отвечает за настройку и управление службами геолокации
    var incomeSegueIdentifier = ""
    var previousLocation: CLLocation? {
        didSet {
            // Обновляем значение каждый раз, когда изменяется местоположение пользователя
            mapManager.startTrackingUserLocation(for: mapView, and: previousLocation) { (currentLocation) in
                self.previousLocation = currentLocation
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                    self.mapManager.showUserLocation(mapView: self.mapView)
                })
            }
        }
    }
    
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
        addressLabel.text = ""
    }
    
    
    // Центрирование View по геолокации
    
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    @IBAction func centerViewInUserLocation() {
        mapManager.showUserLocation(mapView: mapView)
    }
    
    @IBAction func doneButtonPressed() {
        // Захват адреса изи addressLabel для передачи в NewPlaceNewController
        MapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
        
    }
    
    @IBAction func goButtonPressed() {
        
        mapManager.getDirections(for: mapView) { (location) in
            self.previousLocation = location
        }
    }
    
    private func setupMapView() {
        
        goButton.isHidden = true
        
        mapManager.checkLocationServices(mapView: mapView, segueIdentifier: incomeSegueIdentifier) {
            mapManager.locationManager.delegate = self
        }
        
        if incomeSegueIdentifier == "showPlace" {
            mapManager.setupPlacemark(place: place, mapView: mapView)
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
            
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
    
    // Данные метод будет вызываться каждый раз при смене отображаемого на экране региона
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // Получаем координаты из метода getCenterLocation
        let center = mapManager.getCenterLocation(for: mapView)
        // CLGeocoder отвечает за преобразование географических координат и географических названий
        let geocoder = CLGeocoder()
        
        if incomeSegueIdentifier == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: mapView)
             }
        }
        
        // Для освобождения ресурсов, связанных с геокодированием рекомендуется делать отмену отложенного запроса
        geocoder.cancelGeocode()
        
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
        mapManager.checkLocationAutorization(mapView: mapView, segueIdentifier: incomeSegueIdentifier)
    }
}
