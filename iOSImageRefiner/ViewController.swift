//
//  ViewController.swift
//  ImageEditSample
//
//  Created by Allen Snow on 5/26/18.
//  Copyright © 2018 Waggle Bum. All rights reserved.
//

import UIKit

class ViewController: UIViewController,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate,
    ImageEditDelegate {

    let imagePickerController: UIImagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePickerController.delegate = self
    }

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var thumbnailView: UIImageView!
    
    @IBAction func selectImageButtonClick(_ sender: Any) {
        self.selectImage()
    }
    
    private func selectImage() {
        
        let deviceHasCamera = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        
        if (deviceHasCamera) {
            
            let selectImage = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
                self.imagePickerController.allowsEditing = false
                self.imagePickerController.sourceType = UIImagePickerControllerSourceType.camera;
                self.present(self.imagePickerController, animated: true, completion: nil)
            }
            
            selectImage.addAction(cameraAction)
            
            let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
                self.imagePickerController.allowsEditing = false
                self.imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary;
                
                self.present(self.imagePickerController, animated: true, completion: nil)
            }
            
            selectImage.addAction(libraryAction)
            
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            }
            
            selectImage.addAction(cancelAction)
            
            self.present(selectImage, animated: true, completion: nil)
        } else {
            imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Image picker
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let origImage: UIImage? = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.imagePickerController.dismiss(animated: true) {
            
            let storyboard = UIStoryboard(name: "ImageEdit", bundle: nil)
            
            if let _imageEdit = storyboard.instantiateViewController(withIdentifier: "ImageEdit") as? ImageEdit {
                _imageEdit.image = origImage
                
                _imageEdit.imageCropWidth = 240
                _imageEdit.imageCropHeight = 240

                _imageEdit.delegate = self
                
                self.present(_imageEdit, animated: true, completion: nil)
            }
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    public func imageEdited(image: UIImage, thumbnail: UIImage?, scaleFactor: Int) {
        self.thumbnailView.image = thumbnail
        self.imageView.image = image
        
    }
}

