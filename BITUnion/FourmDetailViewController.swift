//
//  FourmDetailViewController.swift
//  BITUnion
//
//  Created by Yin Shuai on 16/3/13.
//  Copyright © 2016年 Michael. All rights reserved.
//

import UIKit
import Alamofire

class FourmDetailViewController: UITableViewController {
  var fid:String = ""
  var fourmDetailList:NSArray = []
  var from:Int = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    performSearch()
    registCell()
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
    tableView.addSubview(refreshControl)

  }
  
  func refresh(refreshControl: UIRefreshControl) {
    // Do your job, when done:
    refreshControl.endRefreshing()
  }
  
  func registCell() {
    let cellNib = UINib(nibName: "FourmTopicCell", bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: "FourmTopicCellIdentifier")
  }
  func performSearch() {
    let parameters = [
      "action":"thread",
      "username":AppData.sharedInstance.username,
      "session":AppData.sharedInstance.session,
      "fid":fid,
      "from":from,
      "to": (from + 20)
    ]
     UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    Alamofire.request(.POST, "http://out.bitunion.org/open_api/bu_thread.php",
      parameters: parameters as? [String : AnyObject],
      encoding: .JSON,
      headers: nil).response { (request, response, data, error) -> Void in
         UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      if let httpResponse = response where httpResponse.statusCode == 200 {
        if let data = data {
          do {
            let forumDetail =  try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            self.fourmDetailList = forumDetail.objectForKey("threadlist") as! NSArray
            dispatch_async(dispatch_get_main_queue()) {
              self.tableView.reloadData()
            }
            
          } catch {
            print(error)
          }
          
        }
      }
    }
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return fourmDetailList.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("FourmTopicCellIdentifier", forIndexPath: indexPath) as! FourmTopicCell
    let dict = fourmDetailList[indexPath.row] as! NSDictionary
    configureCell(cell, withDictionary: dict)
    return cell
  }
  
  func configureCell(cell: UITableViewCell, withDictionary dict:NSDictionary) {
    print(dict)
    let cell = cell as! FourmTopicCell
    cell.topicLabel?.text = dict.objectForKey("subject")?.stringByRemovingPercentEncoding
    cell.authorLabel.text = dict.objectForKey("author")?.stringByRemovingPercentEncoding
    let replies = dict.objectForKey("replies") as! String
    let views = dict.objectForKey("views") as! String
    cell.reviewAndFeedLabel.text = "\(replies)/\(views)"
  }
  
  override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 200
  }
}
