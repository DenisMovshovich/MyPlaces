//
//  RatingControl.swift
//  MyPlaces
//
//  Created by Denis Movshovich on 05/08/2019.
//  Copyright © 2019 Denis Movshovich. All rights reserved.
//

import UIKit

 @IBDesignable class RatingControl: UIStackView { // @IBDesignable необходимо для того, чтобы отобразить созданный контетнт на storyboard
    
    // MARK: Свойства
    
    private var ratingButtons = [UIButton]()
    //Размер кнопки
    // @IBInspectable необходимо для редактирования свойств в storyboard (тип свойства необходимо указать явно!)
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButtons()
        }
    }
    
    // Количество кнопок
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    
    var rating = 0
    
    //MARK: Инициализация
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    // MARK: Button Action
    
    @objc func ratingButtonTapped(button: UIButton) {
        print("Button pressed 🤘🏻")
    }
    
    
    // MARK: Приватные методы
    
    private func setupButtons() {
        
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
        ratingButtons.removeAll()
        
        for _ in 0..<starCount {
            
            // Создаю кнопку
            let button = UIButton()
            button.backgroundColor = #colorLiteral(red: 0.5300177932, green: 0.0657126382, blue: 0.000567090814, alpha: 1)
            
            // Add constraints
            
            // Отключаем автоматически сгенерированные констрейнты для кнопки
            button.translatesAutoresizingMaskIntoConstraints = false
            // Высота и ширина кнопки
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            // Setup the button action
            button.addTarget(self, action: #selector(ratingButtonTapped(button: )), for: .touchUpInside)
            
            // Add the button to stack
            addArrangedSubview(button)
            
            // Add the new button on the rating button array
            ratingButtons.append(button)
        }
    }
}
