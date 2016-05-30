//
//  PostNewTopicViewController.swift
//  BITUnion
//
//  Created by Yin Shuai on 16/4/28.
//  Copyright © 2016年 Michael. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD

class PostNewTopicViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate {
  
  var fid = ""
  var attachment = 1
  var attachImage: UIImage?
  var hud:MBProgressHUD?

  
  @IBOutlet weak var cancelButton: UIBarButtonItem!
  @IBOutlet weak var finishButton: UIBarButtonItem!
  @IBOutlet weak var subjectTextField: UITextField!
  
  @IBOutlet weak var newThreadTextView: UITextView!
  
  @IBOutlet weak var keyboardHeight: NSLayoutConstraint!

  @IBAction func addPhotosOrImage(sender: AnyObject) {
    newThreadTextView.resignFirstResponder()
    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
    if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
      let camera = UIAlertAction(title: "从图库中选择", style: .Default, handler: { [unowned self] action in
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        self.presentViewController(picker, animated: true, completion: nil)
      })
      actionSheet.addAction(camera)
    }
    if UIImagePickerController.isSourceTypeAvailable(.Camera) {
      let camera = UIAlertAction(title: "使用相机拍照", style: .Default, handler: {
        [unowned self] action in
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .Camera
        self.presentViewController(picker, animated: true, completion: nil)
      })
      actionSheet.addAction(camera)
    }
    
    actionSheet.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
    actionSheet.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
    presentViewController(actionSheet, animated: true, completion: nil)
  }
  
    @IBAction func cancelEdit(sender: UIBarButtonItem) {
    newThreadTextView.resignFirstResponder()
    self.dismissViewControllerAnimated(true, completion: nil)

  }
  
  func textFieldDidEndEditing(textField: UITextField) {
    let whitespace = NSCharacterSet.whitespaceAndNewlineCharacterSet()
    if let subject = textField.text?.stringByTrimmingCharactersInSet(whitespace) where subject != "" {
      finishButton.enabled = true
    }
  }
  
  @IBAction func finishEdit(sender: UIBarButtonItem) {
    
    let whitespace = NSCharacterSet.whitespaceAndNewlineCharacterSet()
    let subject = subjectTextField.text?.stringByTrimmingCharactersInSet(whitespace)
    let message = newThreadTextView.text
    let attachFlag = attachImage == nil ? 0 : 1
    let parameters:NSDictionary = [
      "action":"newthread",
      "username":AppData.sharedInstance.username,
      "session":AppData.sharedInstance.session,
      "fid":fid,
      "subject": subject!,
      "message": message,
      "attachment": attachFlag
    ]
    
    print(parameters)
    let data = try! NSJSONSerialization.dataWithJSONObject(parameters, options: .PrettyPrinted)
    print(parameters)
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    let urlString = AppData.getPostURLWithlastComponent("bu_newpost.php")
    
    Alamofire.upload(
      .POST,
      urlString,
      multipartFormData: { multipartFormData in
      multipartFormData.appendBodyPart(data: data, name: "json")
        if let image = self.attachImage {
          guard let imageData = UIImageJPEGRepresentation(image, 0.5) else {
            print("Could not get JPEG representation of UIImage")
            return
          }
          multipartFormData.appendBodyPart(data: imageData, name: "attach",
            fileName: "image.jpg", mimeType: "image/jpeg")
        }
      debugPrint(multipartFormData)
      }, encodingCompletion: { encodingResult in
        switch encodingResult {
        case .Success(let upload, _, _):
          upload.validate()
          self.hud = MBProgressHUD(forView: self.view)
          upload.progress { bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
              let percent = (Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
              self.hud?.progress = percent
            }
          }
          upload.responseJSON { response in
            debugPrint(response)
          }
        case .Failure(let encodingError):
          print(encodingError)
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    })
//    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  
  var frameView : UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    self.finishButton.enabled = false
    self.newThreadTextView.becomeFirstResponder()
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)

  }
  
  func keyboardWillShow(notification:NSNotification) {
    let info = notification.userInfo
    let animationDuration = (info?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
    var keyboardFrame = (info?[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
    keyboardFrame = view.convertRect(keyboardFrame, fromView:view.window)
    let height = keyboardFrame.size.height
    keyboardHeight.constant = height + 5

    UIView.animateWithDuration(animationDuration) {
      self.view.layoutIfNeeded()
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
  }
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    let image = info[UIImagePickerControllerOriginalImage] as? UIImage
    if let image = image {
      self.attachImage = image

//      let width = newThreadTextView.frame.width * 0.8
//      let factor = width / image.size.width
//      let height = image.size.height * factor
      
//      let attachment = NSTextAttachment()
//      attachment.image = image.imageScaledToSize(CGSizeMake(width, height))
//      let attString = NSAttributedString(attachment: attachment)
//      newThreadTextView.textStorage.insertAttributedString(attString, atIndex: newThreadTextView.selectedRange.location)
    }
    dismissViewControllerAnimated(true, completion: nil)
    UIView.animateWithDuration(0.2) {
      self.view.layoutIfNeeded()
    }
  }
}
