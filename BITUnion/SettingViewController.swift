//
//  SettingViewController.swift
//  BITUnion
//
//  Created by Yin Shuai on 16/5/29.
//  Copyright © 2016年 Michael. All rights reserved.
//

import UIKit
import Alamofire

class SettingViewController: UITableViewController {

  @IBAction func showImageOrNot(sender: AnyObject) {
      AppData.sharedInstance.showImage = !AppData.sharedInstance.showImage
    }
  
  @IBAction func isOutofSchool(sender: AnyObject) {
      AppData.sharedInstance.isOutofSchool = !AppData.sharedInstance.isOutofSchool
  }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    

  }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

  override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    if indexPath.section == 2 && indexPath.row == 0 {
      logout()
    }
    return indexPath
  }
  
  
  func logout() {
        
//    let urlString = "http://out.bitunion.org/open_api/bu_logging.php"
    let urlString = AppData.getPostURLWithlastComponent("bu_logging.php")
    
    let parameters = ["action":"logout",
                     "username": AppData.sharedInstance.username,
                     "password": AppData.sharedInstance.password,
                     "session" : AppData.sharedInstance.session]
    
    Alamofire.request(
      .POST,
      urlString,
      parameters: parameters,
      encoding: .JSON,
      headers: nil)
      .response(completionHandler: {
        (urlRequest, response, data, error) -> Void in
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        if let httpResponse = response where
          httpResponse.statusCode == 200 {
          if let jsonData = data {
            do {
              let jsonDict = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
              print(jsonDict)
              AppData.sharedInstance.isLogin = false
              AppData.sharedInstance.password = ""
              AppData.sharedInstance.session = ""
              
              dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.tabBarController?.selectedIndex = 0
              }
            } catch let error as NSError {
              // failure
              print("Fetch failed: \(error.localizedDescription)")
            }
          }
        } else {
//          dispatch_async(dispatch_get_main_queue()) { [unowned self] in
//          }
        }
      })
  }
}
