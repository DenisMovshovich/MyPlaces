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
    @objc dynamic var date = Date()   // Свойство для внутренного использования(для сортировки по дате) 
    
    convenience init(name: String, location: String?, type: String?, imageData: Data?) {
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
    }
}

// тест
// хмхмхм
