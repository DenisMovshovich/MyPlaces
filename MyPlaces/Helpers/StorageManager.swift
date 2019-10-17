//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Denis Movshovich on 03/07/2019.
//  Copyright © 2019 Denis Movshovich. All rights reserved.
//

import RealmSwift

// Создал объект realm, который предоставляет доступ к базе данных(входная точка в базу данных)
let realm = try! Realm()

class StorageManager {
    // Метод для сохранения объектов с типом Place
    static func saveObject(place: Place) {
        // Реализация метода для сохранения объектов в базе данных
        try! realm.write {
            realm.add(place)
        }
    }
    // Метод для удаления объекта из базы данных
    static func deleteObject(place: Place) {
        // Реализация
        try! realm.write {
            realm.delete(place)
        }
    }
}
