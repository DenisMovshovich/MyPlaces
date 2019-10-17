//
//  CustomTableViewCell.swift
//  MyPlaces
//
//  Created by Denis Movshovich on 29/06/2019.
//  Copyright © 2019 Denis Movshovich. All rights reserved.
//

import UIKit
import Cosmos

class CustomTableViewCell: UITableViewCell {

    @IBOutlet var imageOfPlace: UIImageView! {
        didSet {
            imageOfPlace.layer.cornerRadius = imageOfPlace.frame.size.height / 2
            imageOfPlace.clipsToBounds = true
            
        }
    }
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var cosmosView: CosmosView! {
        didSet {
            cosmosView.settings.updateOnTouch = false // Отключение возможности редактирования рейтинга на главном экране
        }
    }
    
}
