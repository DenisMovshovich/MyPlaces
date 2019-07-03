//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Denis Movshovich on 01/07/2019.
//  Copyright © 2019 Denis Movshovich. All rights reserved.
//

import UIKit

class NewPlaceViewController: UITableViewController {
    
    // Создаем экземпляр модели Place
    var newPlace = Place()
    // Вспомогательное свойство, нужное для замены изображения, если пользователь решит добавить свое фото
    var imageIsChanged = false

    @IBOutlet var saveButton: UIBarButtonItem!
    
    @IBOutlet var placeImage: UIImageView!
    @IBOutlet var placeName: UITextField!
    @IBOutlet var placeLocation: UITextField!
    @IBOutlet var placeType: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Реаллизую доступ к объекту сразу же, как он появляется в базе, без обновления интерфейса
        DispatchQueue.main.async {
            self.newPlace.savePlaces()
        }
        
        // Скрываем лишние сепараторы
        tableView.tableFooterView = UIView()
        // Делаем кнопку Save  неактивной по умолчанию
        saveButton.isEnabled = false
        
        // Каждый раз при редактировании текстового поля Name будет вызываться этот метод, который в свою очередь вызывает метод textFieldChanged, который будет следить за тем было ли изменено текстовое поле Name (его реализация ниже)
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
  
    }
    
    // MARK: Table view Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if indexPath.row == 0 {
            
            let cameraIcon = #imageLiteral(resourceName: "camera")
            let photoIcon = #imageLiteral(resourceName: "photo")
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera) // !!!!  В Info.plist нужно добавить ключ NSCameraUsageDescription со значением $(PRODUCT_NAME) photo use
            }
            // Добавил иконку для пункта Camera
            camera.setValue(cameraIcon, forKey: "Image")
            // Выровнял текст для по левому краю
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: "Photo", style: .default) {_ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            // Добавил иконку для пункта Photo
            photo.setValue(photoIcon, forKey: "Image")
            // Выровнял текст для по левому краю
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            present(actionSheet, animated: true)
            
        } else {
            // Скрываем клавиатуру по тапу, если это не первая ячейка
            view.endEditing(true)
        }
    }
    
    func saveNewPlace() {
        
        // Свойство нужное для определения было ли добавлено фото пользователем
        var image: UIImage?
        
        if imageIsChanged {
            image = placeImage.image
        } else {
            image = #imageLiteral(resourceName: "imagePlaceholder")
        }
        
//        newPlace = Place(name: placeName.text!,
//                         location: placeLocation.text,
//                         type: placeType.text,
//                         image: image,
//                         restaurantImage: nil)
    }
    
    // При нажатии на кнопку Cancel произойдет возврат на главный экран
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
}

// MARK: Text field Delegate

extension NewPlaceViewController: UITextFieldDelegate {

    // Скрываем клавиатуру по нажатию на Done

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Этот метод следит за тем, внесены ли данные в текстовое поле. Если внесены, то кнопка Save станет активна
    @objc private func textFieldChanged() {
        
        if placeName.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
}


// MARK: Wofk with image

extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        // Проводим проверку на доступность источника выбора изображения
        if UIImagePickerController.isSourceTypeAvailable(source) {
            // Создаем экземпляр класса
            let imagePicker = UIImagePickerController()
            // Делегируем обязанности по выполнению метода присвоения изображения нашему классу NewPlaceViewController
            imagePicker.delegate = self
            // Позволяем пользователю отредактировать выбранное изображение
            imagePicker.allowsEditing = true
            // Определяем тип источника для выбранного изображения
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    
    // В этом методе мы присваеваем аутлету imageOfPlace выбранное изображение
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Берем значение по ключу .editedImage и присвоили это значение, как UIImage свойству ImageOfPlace
        placeImage.image = info[.editedImage] as? UIImage
        // Далее работаем над форматом выбранного изображения
        placeImage.contentMode = .scaleAspectFill
        // Обрезаем по границам
        placeImage.clipsToBounds = true
        
        imageIsChanged = true
        // Закрываем ImagePickerController
        dismiss(animated: true)
    }
    
}
