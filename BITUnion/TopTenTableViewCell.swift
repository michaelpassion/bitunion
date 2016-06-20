//
//  TopTenTableViewCell.swift
//  BITUnion
//
//  Created by Yin Shuai on 16/6/6.
//  Copyright © 2016年 Michael. All rights reserved.
//

import UIKit

class TopTenTableViewCell: UITableViewCell {

  @IBOutlet weak var replyTimeLabel: UILabel!
  @IBOutlet weak var replayAuthorLabel: UILabel!
  @IBOutlet weak var replayAvantarImageView: UIImageView!
  @IBOutlet weak var subject: UILabel!
  @IBOutlet weak var replayContent: UILabel!
  
  var tid = ""
  var totalNum = 0
  
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  override func prepareForReuse() {
    super.prepareForReuse()
    
    replayContent.text = ""
    replyTimeLabel.text = ""
    replayAuthorLabel.text = ""
    subject.text = ""
    replayAvantarImageView.image = nil
  }
  

}
