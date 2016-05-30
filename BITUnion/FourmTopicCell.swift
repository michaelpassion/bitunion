//
//  FourmTopicCell.swift
//  BITUnion
//
//  Created by Yin Shuai on 16/3/13.
//  Copyright © 2016年 Michael. All rights reserved.
//

import UIKit
import DTCoreText

class FourmTopicCell: UITableViewCell {

  @IBOutlet weak var topicLabel: UILabel!
  @IBOutlet weak var authorLabel: UILabel!
  @IBOutlet weak var postTimeLabel: UILabel!
  @IBOutlet weak var reviewAndFeedLabel: UILabel!
  
  var tid:String = ""
  var totalNum = 0
  
  override func prepareForReuse() {
    topicLabel.text = ""
    authorLabel.text = ""
    postTimeLabel.text = ""
    reviewAndFeedLabel.text = ""
  }
}
