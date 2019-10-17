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
    
    var rating = 0 {
        didSet {
            updateButtonSelectionState()
        }
    }
    
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
        // Определяем индекс кнопки, которой касается пользователь
        guard let index = ratingButtons.firstIndex(of: button) else { return }
        
        // Calculate the rating of the selected button
        let selectedRating = index + 1
        
        if selectedRating == rating { // Если номер выбранной звезды будет совпадать с текущим рейтингом, то обнуляем рейтинг
            rating = 0
        } else { // В противном случае присваиваем рейтингу значение  выбранной звезды
            rating = selectedRating
        }
    }
    
    
    // MARK: Приватные методы
    
    private func setupButtons() {
        
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
        ratingButtons.removeAll()
        
        // Load button image
        let bundle = Bundle(for: type(of: self))
        let filledStar = UIImage(named: "filledStar",
                                 in: bundle,
                                 compatibleWith: self.traitCollection)
        
        let emptyStar = UIImage(named: "emptyStar",
                                in: bundle,
                                compatibleWith: self.traitCollection)
        
        let hightlightedStar = UIImage(named: "hightlightedStar",
                                       in: bundle,
                                       compatibleWith: self.traitCollection)
        
        
        for _ in 0..<starCount {
            
            // Создаю кнопку
            let button = UIButton()
            
            // Set the button image
            button.setImage(emptyStar, for: .normal) // обычное состояние кнопки, когда она не выделена, не нажата и не в фокусе
            button.setImage(filledStar, for: .selected) // кнопка выделена
            button.setImage(hightlightedStar, for: .highlighted) // выделение кнопки при прикосновении
            button.setImage(hightlightedStar, for: [.highlighted, .selected]) // выделение кнопки при прикосновении(синим) и при выделении(черным)
            
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
        
        updateButtonSelectionState()
    }
    
    private func updateButtonSelectionState() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
}
