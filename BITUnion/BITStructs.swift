//
//  BITthStructs.swift
//  BITUnion
//
//  Created by Yin Shuai on 16/3/24.
//  Copyright © 2016年 Michael. All rights reserved.
//

import Foundation
import DTCoreText

struct BITThread {
  var tid: Int
  var time: String
  var author: String
  var authorID: String
  var avantaURL: NSURL
  var floor: Int
  var htmlString: String
  var attributedParagraph = NSAttributedString()
  var attachments:String
  var attachsize:String
  var attachext:String
  
  func stringByDecodeingHTMLCharacters(htmlText: String) -> NSAttributedString? {
    
    let sEncode = htmlText.stringByReplacingOccurrencesOfString("+", withString: " ")
    let attributedOptions: [NSObject: AnyObject] = [
      NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
      NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding,
      DTDefaultFontFamily : "Times New Roman",
      DTDefaultLinkColor : "purple",
      DTDefaultLinkHighlightColor : "red",
      DTDefaultFontSize : "20.0f"
    ]

    if let sDecode = sEncode.stringByRemovingPercentEncoding,
      let data = sDecode.dataUsingEncoding(NSUTF8StringEncoding),
      let attrString = try? NSAttributedString(data: data,
                                            options: attributedOptions as! [String : AnyObject], documentAttributes: nil) {
      return attrString
    }
    return nil
  }

  struct ImageInfo {
    var thumbnailURL: NSURL
    var fullImageURL: NSURL
    var imageName: String
    var imageSize: Int
  }

  struct Attachment {
    var name: String
    var pos: Int
    var size: Int
  }
  
}