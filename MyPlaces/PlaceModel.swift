//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Denis Movshovich on 29/06/2019.
//  Copyright © 2019 Denis Movshovich. All rights reserved.
//

import UIKit

struct Place {
    var name: String
    var location: String?
    var type: String?
    var image: UIImage?
    var restaurantImage: String?
    
    static let restauranNames = ["Burger King", "Шок", "Бочка", "Индокитай", "Sushi House", "Пепперони", "Sherlock's Pub", "Kitchen", "Love&Life", "Speak Easy", "Балкан Гриль"]
    
    static func getPlaces() -> [Place] {
        
        var places = [Place]()
        
        for place in restauranNames {
            places.append(Place(name: place, location: "Казань", type: "Ресторан", image: nil, restaurantImage: place))
        }
        return places
    }
}


