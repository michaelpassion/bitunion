
//
//  TopTenTableViewController.swift
//  BITUnion
//
//  Created by Yin Shuai on 16/3/10.
//  Copyright © 2016年 Michael. All rights reserved.
//

import UIKit
import Foundation
import Alamofire


class FourmListViewController: UITableViewController {
  var sectionList = NSArray()
  var isLogin = false
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if NSFileManager.defaultManager().fileExistsAtPath(dataFilepath()) {
        sectionList = NSArray(contentsOfFile: dataFilepath())!
    } else {
        print("file not exist")
    }
//    tableView.tableFooterView = UIView(frame: CGRect.zero)
    self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

  }
  
  func showloginScreen(animated: Bool) {
    let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
    let loginViewController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
    self.presentViewController(loginViewController, animated: animated, completion: nil)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if !AppData.sharedInstance.isLogin {
      showloginScreen(true)
    }

  }
  
  func documentsDirectory() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    return paths[0]
  }
  
  func dataFilepath() -> String {
    return (self.nibBundle?.pathForResource("data/BUCForumList", ofType: "plist"))!
  }
}


extension FourmListViewController {
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let dict = sectionList[section]
    let subArray = dict.objectForKey("list") as! NSArray
    return subArray.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("FourmListCell", forIndexPath: indexPath)
    configureCell(cell, atIndexPath: indexPath)
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      return sectionList.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

      return (sectionList[section]).objectForKey("name") as? String
    }
    
  func configureCell(cell :UITableViewCell , atIndexPath indexPath: NSIndexPath) {
    let dict = sectionList[indexPath.section]
    let subArray = dict.objectForKey("list") as! NSArray
    let subDict = subArray[indexPath.row]
    cell.textLabel?.text = subDict.objectForKey("name") as? String
    cell.textLabel?.textColor = UIColor(red: 34/255, green: 49/255, blue: 63/255, alpha: 1)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ForumDetail" {
      let controller = segue.destinationViewController as! FourmDetailViewController
      let cell = sender as! UITableViewCell
      let indexPath:NSIndexPath = tableView.indexPathForCell(cell)!
      
      let dict = sectionList[indexPath.section]
      let subArray = dict.objectForKey("list") as! NSArray
      let subDict = subArray[indexPath.row]
      controller.fid = subDict.objectForKey("fid") as! String
      controller.navigationBar.title = subDict.objectForKey("name") as? String
    }
  }
//  override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//    let sections = tableView.numberOfSections
//    if (section == sections - 1) {
//      let tabBarHeight = self.tabBarController?.tabBar.frame.height;
//      return  tabBarHeight! + 5
//    } else {
//      return 0
//    }
//    
//  }
  
}
