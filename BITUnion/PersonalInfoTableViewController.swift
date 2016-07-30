//
//  PersonalInfoTableViewController.swift
//  BITUnion
//
//  Created by Yin Shuai on 16/6/26.
//  Copyright © 2016年 Michael. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class PersonalInfoTableViewController: UITableViewController {
  
  var uid = ""
  var queryName = ""
  var request: Alamofire.Request?
  var avatarImage: UIImage?
  

  override func viewDidLoad() {
      super.viewDidLoad()
      performSearch()
    self.navigationItem.title = queryName

  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    self.request?.cancel()
  }
  
  func performSearch() {
    
    let parameters = [
      "action":"profile",
      "username":AppData.sharedInstance.username,
      "session":AppData.sharedInstance.session,
      "queryusername":queryName
    ]
    
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    let urlString = AppData.getPostURLWithlastComponent("bu_profile.php")
    self.request = Alamofire.request(
      .POST,
      urlString,
      parameters: parameters,
      encoding: .JSON,
      headers: nil)
    
    if let _ = request {
      self.request!.response {
        (request, response, data, error) -> Void in
        if let httpResponse = response
          where httpResponse.statusCode == 200 {
          if let data = data {
            do {
              let topicDetail:NSDictionary =  try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
              
              if AppData.checkIfSessionTimeOut(topicDetail) {
                AppData.updateSession() { [unowned self] in
                  self.performSearch()
                }
              }
              
              
              dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.modifyInformation(topicDetail)

                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
              }
              
            } catch {
              print(error)
            }
          }
        }
      }
    }
  }

  func modifyInformation(dict: NSDictionary)  {
    
    if let memberinfo = dict["memberinfo"]{
      
      print(memberinfo.description)
      
      let url = NSURL()
      let imageView = self.view.viewWithTag(1000) as? UIImageView
      imageView?.sd_setImageWithURL(url, placeholderImage: UIImage.init(named: "defaultAvantar.gif"))
      imageView?.image = self.avatarImage

      let group = self.view.viewWithTag(1001) as? UILabel
      group?.text = memberinfo["status"] as? String
      
      let regtime = self.view.viewWithTag(1002) as? UILabel
      regtime?.text = getTimeStringFormUnixTime(memberinfo.objectForKey("regdate") as! String)
      

      let lastLoginTime = self.view.viewWithTag(1003) as? UILabel
      lastLoginTime?.text = getTimeStringFormUnixTime(memberinfo.objectForKey("lastvisit") as! String)
    }
  }
  
  func getTimeStringFormUnixTime(date:String) -> String? {
    let date = NSDate(timeIntervalSince1970: Double(date)!)
    var text = (date.description) as NSString
    text = text.substringToIndex(10)
    return text as String
  }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }

}
