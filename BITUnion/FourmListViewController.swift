
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
  var isLogin = false
  var sectionList = NSArray()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if NSFileManager.defaultManager().fileExistsAtPath(dataFilepath()) {
        sectionList = NSArray(contentsOfFile: dataFilepath())!
    } else {
        print("file not exist")
    }
    tableView.tableHeaderView = UIView(frame: CGRect.zero)
    
  }
  

//  func refreshFourmList() {
//    let userDefalut = NSUserDefaults.standardUserDefaults()
//        let parameters = [ "action":"forum",
//      "username":userDefalut.valueForKey("username") as! String,
//      "session":userDefalut.valueForKey("session") as! String]
//    
//    
//      Alamofire.request(.POST, "http://out.bitunion.org/open_api/bu_forum.php", parameters: parameters, encoding: .JSON, headers: nil).response {
//      (request, response, data, ERROR) -> Void in
//      if let httpResponse = response  where httpResponse.statusCode == 200,
//        let data = data {
//          do {
//            let dict:NSDictionary =
//            try NSJSONSerialization.JSONObjectWithData(data,
//              options: .AllowFragments) as! NSDictionary
//            
//            if dict.objectForKey("result") as! String == "success" {
//              self.jsonDictinary = dict["forumslist"] as! NSDictionary
//              dispatch_async(dispatch_get_main_queue()) {
//                self.tableView.reloadData()
//              }
//            }
//          }
//          catch {
//            print("error")
//          }
//      }
//    }
//  }
//  
  
  func documentsDirectory() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    return paths[0]
  }
  
  func dataFilepath() -> String {
//    return (documentsDirectory() as NSString).stringByAppendingPathComponent("BUCForumList.plist")
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
//    performSegueWithIdentifier("forumDetail", sender: self)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      return sectionList.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//      var keys = jsonDictinary.allKeys
//      var dict = NSMutableDictionary()
//      let key = keys[section] as! String
//      
//      if key != "" {
//        dict = jsonDictinary.objectForKey(key) as! NSMutableDictionary
//        dict = dict.objectForKey("main") as! NSMutableDictionary
//        let name = dict.objectForKey("name") as! String
//       return name.stringByRemovingPercentEncoding
//      }
//      return "xx"
      return (sectionList[section]).objectForKey("name") as? String
    }
    
//    
//    func getSectionHeader(index: Int) -> String {
//      var keys = jsonDictinary.allKeys
//      var dict = NSMutableDictionary()
//      let key = keys[index] as! String
//      
//      if key != "" {
//        dict = jsonDictinary.objectForKey(key) as! NSMutableDictionary
//        dict = dict.objectForKey("main") as! NSMutableDictionary
//        let name = dict.objectForKey("name") as! String
//        return name.stringByRemovingPercentEncoding!
//      }
//      return "in array"
//    }
  
  func configureCell(cell :UITableViewCell , atIndexPath indexPath: NSIndexPath) {
//      let keys = jsonDictinary.allKeys
//      let key = keys[indexPath.section] as! String
//      if key == "" {
//        cell.textLabel?.text = "mark"
//        return
//      }
//      let secondLevelDict = jsonDictinary[key] as! NSDictionary
//      let secondLevelKeys = secondLevelDict.allKeys
//      let secondLevelKey = secondLevelKeys[indexPath.row] as! String
//      let thirdLevelDict = secondLevelDict[secondLevelKey] as! NSDictionary
//      
//      print(thirdLevelDict)
//      
//      cell.textLabel?.text = thirdLevelDict["name"]?.stringByRemovingPercentEncoding
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
    }
  }
  
//  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//    let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
//    headerView.backgroundColor = UIColor(red: 228/255, green: 241/255, blue: 254/255, alpha: 1)
//    return headerView
//  }
}
