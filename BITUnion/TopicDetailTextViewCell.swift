//
//  TopicDetailTextViewCell.swift
//  BITUnion
//
//  Created by Yin Shuai on 16/3/20.
//  Copyright © 2016年 Michael. All rights reserved.
//

import UIKit
import DTCoreText
import MediaPlayer
import JTSImageViewController
import MBProgressHUD
import AVKit
import AVFoundation
import MediaPlayer



class TopicDetailTextViewCell:  DTAttributedTextCell,
DTAttributedTextContentViewDelegate,JTSImageViewControllerInteractionsDelegate,
DTLazyImageViewDelegate, UIActionSheetDelegate {
  
  @IBOutlet weak var floor: UILabel!
  @IBOutlet weak var author: UILabel!
  @IBOutlet weak var posttime: UILabel!
  @IBOutlet weak var avatar: UIImageView!
  @IBOutlet weak var message: DTAttributedTextContentView!
  
  @IBOutlet weak var quote: UIButton!
  static let controller = UIViewController()
  let indicator = UIActivityIndicatorView()
  var tid = ""
  var topicText = ""

  @IBAction func quoteToPost(sender: AnyObject) {
    let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
    let navigtionController = storyboard.instantiateViewControllerWithIdentifier("PostNewTopicNavgationViewController") as! UINavigationController
    let replyViewController = navigtionController.topViewController as! PostNewTopicViewController
    self.window?.makeKeyAndVisible()
    replyViewController.isReplay = true
    replyViewController.tid = self.tid
    replyViewController.topicText = self.topicText
    let htmlString =  self.message.attributedString.htmlString()
    
    // HTML to UBB
    replyViewController.qutoeText = ""
    self.window?.rootViewController?.presentViewController(navigtionController, animated: true, completion: nil)
  }
  
  var mediaPlayers = NSMutableSet()
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

  }
  
  override func prepareForReuse() {
    self.message.attributedString = nil
    self.avatar.image = nil
  
  }

  func lazyImageView(lazyImageView: DTLazyImageView!, didChangeImageSize size: CGSize) {
    let url = lazyImageView.url
    let imageSize = size
    
    let pred = NSPredicate.init(format: "contentURL == %@", url)
    
    var didUpdate = false
    
    for  oneAttachment in message.layoutFrame.textAttachmentsWithPredicate(pred) {
      // update attachments that have no original size, that also sets the display size
      if CGSizeEqualToSize(oneAttachment.originalSize, CGSizeZero) {
        (oneAttachment as! DTTextAttachment).originalSize = imageSize
        didUpdate = true
      }
      if (didUpdate)
      {
        // layout might have changed due to image sizes
        message.relayoutText()
      }
    }
  }
  
  
  func attributedTextContentView(attributedTextContentView: DTAttributedTextContentView!, viewForAttachment attachment: DTTextAttachment!, frame: CGRect) -> UIView! {
    if attachment is DTImageTextAttachment {
      let imageView = DTLazyImageView(frame: frame)
      imageView.delegate = self

      
      imageView.image = (attachment as! DTImageTextAttachment).image
      imageView.shouldShowProgressiveDownload = true
      imageView.contentMode = .ScaleAspectFit
      
      imageView.url = attachment.contentURL

      
      
      imageView.userInteractionEnabled = true;
      let press = UITapGestureRecognizer(target: self, action: #selector(picturePressed(_:)))
      imageView.addGestureRecognizer(press)
      
      return imageView
      
    } else if attachment is DTVideoTextAttachment {
      
      let url = attachment.contentURL
      
      // we could customize the view that shows before playback stars
      let grayView = UIView(frame: frame)
      grayView.backgroundColor = UIColor.blackColor()
  
      let playerItem = AVPlayerItem(URL: url)
      let player = AVPlayer(playerItem: playerItem)
      let playerLayer = AVPlayerLayer(player: player)
      playerLayer.frame = grayView.bounds
      return  grayView
      
    }
    return nil
  }
  
  func attributedTextContentView(attributedTextContentView: DTAttributedTextContentView!, shouldDrawBackgroundForTextBlock textBlock: DTTextBlock!, frame: CGRect, context: CGContext!, forLayoutFrame layoutFrame: DTCoreTextLayoutFrame!) -> Bool {
    let roundedRect = UIBezierPath.init(roundedRect: CGRectInset(frame, 1, 1), cornerRadius: 10)
    if let color = textBlock.backgroundColor?.CGColor{
      CGContextSetFillColorWithColor(context, color)
      CGContextAddPath(context, roundedRect.CGPath)
      CGContextFillPath(context)
      
      CGContextAddPath(context, roundedRect.CGPath)
      CGContextSetRGBStrokeColor(context, 0, 0, 0, 1)
      CGContextStrokePath(context)
      return false
    }
    return true
  }

  func attributedTextContentView(attributedTextContentView: DTAttributedTextContentView!, viewForAttributedString string: NSAttributedString!, frame: CGRect) -> UIView! {
    let attributes = string.attributesAtIndex(0, effectiveRange: nil)
    let url = attributes[DTLinkAttribute] as? NSURL
    let identifier = attributes[DTGUIDAttribute] as? String
    
    let button = DTLinkButton(frame: frame)
    button.URL = url
    button.minimumHitSize = CGSizeMake(25, 25) // adjusts its bounds so that button is always large enough
    button.GUID = identifier
    
    // get image with normal link text
    let normalImage = attributedTextContentView.contentImageWithBounds(frame, options: .Default)
    button.setImage(normalImage, forState: .Normal)
    
    // get image for highlighted link text
    let highlightImage = attributedTextContentView.contentImageWithBounds(frame, options: .DrawLinksHighlighted)
    button.setImage(highlightImage, forState: .Highlighted)
    
    //use normal push action for opening URL
    button.addTarget(self, action: #selector(urlClicked(_:)), forControlEvents:.TouchUpInside)
    
    // demonstrate combination with long press
    let longPress = UILongPressGestureRecognizer(target: self, action: #selector(linkLongPressed(_:)))
    button.addGestureRecognizer(longPress)
    
    return button
    
  }
  
  func urlClicked(gestrue:UITapGestureRecognizer)  {
    print("")
  }
  
  func linkLongPressed(gesture: UILongPressGestureRecognizer) {
    if gesture.state == .Began {
      if let button = gesture.view as? DTLinkButton {
        button.highlighted = false
//        self.lastActionLink = button.URL
        if UIApplication.sharedApplication().canOpenURL(button.URL.absoluteURL) {
          let alertController = UIAlertController(title: button.URL.absoluteURL.description, message: nil, preferredStyle: .ActionSheet)
          let cancelAction = UIAlertAction(title: "cancel", style: .Cancel, handler: nil)
          let openAction = UIAlertAction(title: "Open in Safari", style: .Default, handler: { (UIAlertAction) in
            UIApplication.sharedApplication().openURL(button.URL.absoluteURL)
          })
          alertController.addAction(cancelAction)
          alertController.addAction(openAction)
          self.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
        }
      }
    }
  }
  
  func picturePressed(sender:UITapGestureRecognizer)  {
    let imageView = sender.view as! UIImageView
    let image = imageView.image
    
    let imageInfo = JTSImageInfo()
    
    imageInfo.image = image
    imageInfo.referenceRect = imageView.frame
    imageInfo.referenceView = imageView.superview
    imageInfo.referenceContentMode = imageView.contentMode
    imageInfo.referenceCornerRadius = imageView.layer.cornerRadius
    
    let imageViewer = JTSImageViewController(imageInfo: imageInfo,
                                             mode: .Image,
                                             backgroundStyle: .Blurred)
    imageViewer.interactionsDelegate = self
    let controller = self.window?.rootViewController
    imageViewer.showFromViewController(controller, transition: .FromOriginalPosition)
    
  }
  
  func imageViewerDidLongPress(imageViewer: JTSImageViewController!, atRect rect: CGRect) {
    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
    let savePhotoAction = UIAlertAction(title: "保存到相册", style: .Default) { [unowned self](alertAction) -> Void in
      let image = imageViewer.image
      UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    actionSheet.addAction(savePhotoAction)
    let copyPhotoAction = UIAlertAction(title: "复制", style: .Default) {
    (alertAction) -> Void in
      UIPasteboard.generalPasteboard().image = imageViewer.image
      let hud = MBProgressHUD.showHUDAddedTo(UIApplication.sharedApplication().keyWindow, animated: true)
      hud.mode = .Text
      hud.labelText = "复制成功"
      hud.hide(true, afterDelay: 1)
    }
    actionSheet.addAction(copyPhotoAction)
    actionSheet.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
    actionSheet.popoverPresentationController?.sourceView = imageViewer.view
    actionSheet.popoverPresentationController?.sourceRect = rect
    imageViewer.presentViewController(actionSheet, animated: true, completion: nil)
  }
  
  func imagedidSaveWithError(error: NSError?)  {
    let hud = MBProgressHUD.showHUDAddedTo(UIApplication.sharedApplication().keyWindow, animated: true)
    hud.mode = .Text
    if error == nil {
      hud.labelText = "保存成功"
      hud.hide(true, afterDelay: 1)
    } else {
      hud.labelText = "请在设置中开启相册访问权限"
      hud.hide(true, afterDelay: 2)
    }
  }
  
  func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
    let hud = MBProgressHUD.showHUDAddedTo(UIApplication.sharedApplication().keyWindow, animated: true)
    hud.mode = .Text

    guard error == nil else {
      //Error saving image
      hud.labelText = "请在设置中开启相册访问权限"
      hud.hide(true, afterDelay: 2)
      return
    }
    //Image saved successfully
    hud.labelText = "保存成功"
    hud.hide(true, afterDelay: 1)
  }

}
