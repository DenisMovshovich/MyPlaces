//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Denis Movshovich on 01/07/2019.
//  Copyright © 2019 Denis Movshovich. All rights reserved.
//

import UIKit

class NewPlaceViewController: UITableViewController {

    @IBOutlet var imageOfPlace: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Скрываем лишние сепараторы
        tableView.tableFooterView = UIView()
  
    }
    
    // MARK: Table view Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if indexPath.row == 0 {
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera) // !!!!  В Info.plist нужно добавить ключ NSCameraUsageDescription со значением $(PRODUCT_NAME) photo use
            }
            
            let photo = UIAlertAction(title: "Photo", style: .default) {_ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            
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
}

// MARK: Text field Delegate

extension NewPlaceViewController: UITextFieldDelegate {

    // Скрываем клавиатуру по нажатию на Done

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
        imageOfPlace.image = info[.editedImage] as? UIImage
        // Далее работаем над форматом выбранного изображения
        imageOfPlace.contentMode = .scaleAspectFill
        // Обрезаем по границам
        imageOfPlace.clipsToBounds = true
        // Закрываем ImagePickerController
        dismiss(animated: true)
    }
    
}
