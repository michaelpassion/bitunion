//
//  TopTenTableViewController.swift
//  BITUnion
//
//  Created by Yin Shuai on 16/6/2.
//  Copyright © 2016年 Michael. All rights reserved.
//

import UIKit
import Alamofire
import MJRefresh

class TopTenTableViewController: UITableViewController {
  
  let getImageRootURL = "http://out.bitunion.org/"
  
  var topTenList = []
  let header = MJRefreshNormalHeader()
  let footer = MJRefreshAutoStateFooter()
  var request: Alamofire.Request?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    header.setRefreshingTarget(self, refreshingAction: #selector(TopTenTableViewController.performSearch))
    self.tableView.mj_header = header
    header.lastUpdatedTimeLabel.hidden = true
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100.0;
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if AppData.sharedInstance.isLogin {
      performSearch()
    }
  }

  func performSearch() {
    let parameters = [
      "username":AppData.sharedInstance.username,
      "session":AppData.sharedInstance.session]
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    
    self.request?.cancel()
    let urlString = AppData.getPostURLWithlastComponent("bu_home.php")
    self.request = Alamofire.request(.POST, urlString,
                                     parameters: parameters ,
                                     encoding: .JSON,
                                     headers: nil)
    
    if let _ = request {
      self.request!.response {
        (request, response, data, error) -> Void in
        if let httpResponse = response
          where httpResponse.statusCode == 200 {
          if let data = data {
            do {
              let responseDict:NSDictionary =  try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
              debugPrint(responseDict)
              if AppData.checkIfSessionTimeOut(responseDict) {
                AppData.updateSession() { [unowned self] in
                  self.performSearch()
                }
              }
              
              guard responseDict["result"] as? String == "success" else {
                print("json serialization error")
                return
              }
              
              if let topTenArray = responseDict["newlist"] as? NSArray {
                self.topTenList = topTenArray
                print(self.topTenList.count)
              } else {
                print("there is not top ten")

              }
              dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                if self.tableView.mj_header.state == MJRefreshState.Refreshing {
                  self.header.endRefreshing()
                }
              }
              
            } catch {
              print(error)
            }
          }
        }
      }
    }
    
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return topTenList.count
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
//    performSegueWithIdentifier("TopicDetail", sender: tableView.cellForRowAtIndexPath(indexPath))
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("TOPTENCELL", forIndexPath: indexPath) as! TopTenTableViewCell
    
    let dict = topTenList[indexPath.row] as! NSDictionary
    configureCell(cell, withDictionary: dict)
    return cell
  }
  
  override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 88
  }

  func configureCell(cell: UITableViewCell, withDictionary dict:NSDictionary) {
    let cell = cell as! TopTenTableViewCell
    let htmlString = dict.objectForKey("pname")!.stringByRemovingPercentEncoding
    let attributedString = htmlString!!.stringByReplacingOccurrencesOfString("+", withString: " ")
    cell.subject.text = attributedString
    
    if let url = dict["avatar"] as? String {
      let urlString = getImageRootURL + url.stringByRemovingPercentEncoding!
      let URL = NSURL(string: urlString)
      let image = UIImage(named: "defaultAvantar.gif")
      cell.replayAvantarImageView.sd_setImageWithURL(URL, placeholderImage: image, options: .ProgressiveDownload)
    } else {
      let image = UIImage(named: "defaultAvantar.gif")
      cell.replayAvantarImageView.image = image
    }
    if let replyDict = dict["lastreply"] as? NSDictionary {
      let content = replyDict["what"] as? String
      cell.replayContent.attributedText = NSAttributedString(string: (content?.stringByRemovingPercentEncoding)!)
      let replayAuthor = (replyDict["who"] as? String)! + "回复了主题"
      cell.replayAuthorLabel.text = replayAuthor.stringByRemovingPercentEncoding
      let timeString = replyDict["when"] as? String
      cell.replyTimeLabel.text = timeString
      let tid = dict["tid"] as! String
      cell.tid = tid
      let totalNum = dict["tid_sum"] as! String
      cell.totalNum = Int(totalNum)!
    }
  }
  
  func convertDatetoRelativeTime(time:String) -> String {
    return ""
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated);
    self.request?.cancel()
    self.request = nil
    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    
    print("viewwilldisapper")
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "TopTenDetail" {
      let controller = segue.destinationViewController as! TopicDetailTableViewController
      
      let cell = sender as! TopTenTableViewCell
      controller.tid = cell.tid
      controller.totalNum = cell.totalNum
      controller.topicTitle = cell.subject.text!

    }

  }
  
}
