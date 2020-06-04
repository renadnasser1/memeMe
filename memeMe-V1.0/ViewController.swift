//
//  ViewController.swift
//  memeMe-V1.0
//updated
//  Created by Renad nasser on 04/06/2020.
//  Copyright © 2020 Renad nasser. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate , UITextFieldDelegate{
    
    //MARK: - Outlet
    @IBOutlet weak var imgeView: UIImageView!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var topTextField: UITextField!
    
    @IBOutlet weak var bottomTextFiled: UITextField!
    
    @IBOutlet weak var topToolbar: UIToolbar!
    
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    //MARK: - Proprites
    
    var activeTextField: UITextField!
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth:  -4,
    ]
    
    
    //MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set all neccessry attribute for topTextField
        topTextField.delegate = self
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = .center
        
        
        //Set all neccessry attribute for buttonTextFiled
        bottomTextFiled.delegate = self
        bottomTextFiled.defaultTextAttributes = memeTextAttributes
        bottomTextFiled.textAlignment = .center
        shareButton.isEnabled=false
        
        //set TOP and BOTTOM
        setTextFiled()
    }
    
    func setTextFiled(){
        topTextField.text = "TOP"
        bottomTextFiled.text = "BOTTOM"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    //MARK: - Pick An Image From Album
    
    @IBAction func pickAnImageFromAlbum(_ sender:Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    //Once add the two method the image picker is no longer automatically dismissed, Need dissmis to be called
    
    // user pick a photo
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        
        
        // assign selected photo to image view
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imgeView.image = image
            
            //set TOP and BOTTOM once pick new photo
            setTextFiled()
        }
        
        shareButton.isEnabled=true
        
        dismiss(animated: true, completion: nil)
        
    }
    
    // user click on cancel
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: - Pick An Image From Camera
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    //MARK: - Text filed delegate method
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.activeTextField = textField
        
        if topTextField.text=="TOP" && textField == topTextField {
            topTextField.text=""
        }
        
        if bottomTextFiled.text=="BOTTOM" && textField == bottomTextFiled {
            bottomTextFiled.text=""
        }
        
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //MARK: - Shift view up when keyboard is show and down after dismiss
    
    @objc func keyboardWillShow(_ notification:Notification) {
        
        
        if view.frame.origin.y == 0 && activeTextField == bottomTextFiled {
            view.frame.origin.y -= getKeyboardHeight(notification)}
    }
    
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    
    @objc func keyboardWillHide(_ notification:Notification) {
        self.view.frame.origin.y = 0
        
    }
    
    
    
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: Share
    
    @IBAction func share(){
        
        let image = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        self.present(controller, animated: true, completion: save)
        
        
        
        
        
    }
    
    
    func save() {
        
        // Create the meme
        let memedImage =  generateMemedImage()
        
        // Create an object
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextFiled.text!, originalImage: imgeView.image!, memedImage: memedImage)
        
        //To save it directly
        // UIImageWriteToSavedPhotosAlbum(memedImage,nil,nil,nil)
        
        
    }
    
    func generateMemedImage() -> UIImage {
        
        //Hide toolbars
        topToolbar.isHidden=true
        bottomToolbar.isHidden=true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //Show toolbars
        topToolbar.isHidden=false
        bottomToolbar.isHidden=false
        
        return memedImage
    }
    
    
    
}




