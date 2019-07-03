//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Denis Movshovich on 29/06/2019.
//  Copyright © 2019 Denis Movshovich. All rights reserved.
//

import RealmSwift

class Place: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData: Data?
    
    let restauranNames = ["Burger King", "Шок", "Бочка", "Индокитай", "Sushi House", "Пепперони", "Sherlock's Pub", "Kitchen", "Love&Life", "Speak Easy", "Балкан Гриль"]
    
    func savePlaces() {
        
        for place in restauranNames {
            // Создал свойство, которое принимает изображение по названию изображения
            let image = UIImage(named: place)
            // Конвертирую UIImage в Data
            guard let imageData = image?.pngData() else { return }
            // Создал экземпляр модели Place
            let newPlace = Place()
            // Присвоил значения свойства экземпляра
            newPlace.name = place
            newPlace.location = "Казань"
            newPlace.type = "Ресторан"
            newPlace.imageData = imageData

            StorageManager.saveObject(place: newPlace)
        }
        
    }
}


