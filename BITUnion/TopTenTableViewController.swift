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
  var firstTime = false;
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.tableFooterView = UIView(frame: CGRect.zero)
    tableView.tableHeaderView = UIView(frame: CGRect.zero)

    header.setRefreshingTarget(self, refreshingAction: #selector(performSearch))
    self.tableView.mj_header = header
    header.lastUpdatedTimeLabel.hidden = true
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100.0;
    
//    if AppData.sharedInstance.isLogin {
//      self.tableView.mj_header.beginRefreshing()
//    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if !firstTime && AppData.sharedInstance.isLogin{
      performSearch()
      firstTime = true
    }
  }

  func performSearch() {
    
    let parameters = [
      "username":AppData.sharedInstance.username,
      "session":AppData.sharedInstance.session]
    self.tableView.mj_header.beginRefreshing()

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
              dispatch_async(dispatch_get_main_queue()) { [unowned self] in
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
    
    let tmp = dict.objectForKey("pname")!.stringByRemovingPercentEncoding!!.stringByReplacingOccurrencesOfString("+", withString: " ")
    let htmlString = "<span style=\"font-family: system; font-size: 16\">\(tmp)</span>"
    
    let encodedData = htmlString.dataUsingEncoding(NSUnicodeStringEncoding)!
    let attributedOptions = [
      NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType]
    do {
      let attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
      cell.subject.attributedText = attributedString
    } catch _ {
      print("cannot create attribted String")
    }
    

    
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
      let time = timeString!.stringByRemovingPercentEncoding?.stringByReplacingOccurrencesOfString("+", withString: " ")
      cell.replyTimeLabel.text = convertDatetoRelativeTime(time!)
      let tid = dict["tid"] as! String
      cell.tid = tid
      let totalNum = dict["tid_sum"] as! String
      cell.totalNum = Int(totalNum)!
    }
  }
  
  func convertDatetoRelativeTime(time:String) -> String {
    let dateForMatter = NSDateFormatter()
    dateForMatter.dateFormat="yyyy-MM-dd HH:mm"
    let date = dateForMatter.dateFromString(time)
    
    let now = NSDate()
    var timeInterval = now.timeIntervalSinceDate(date!)
    
    var result:String?
    
    if (timeInterval < 60) {
      result = "刚刚"
    } else if ( timeInterval < 60 * 60) {
      result = "\(Int(timeInterval/60))分钟前"
    } else if (timeInterval < 60 * 60 * 24) {
      result = "\(Int(timeInterval/(60*60)))小时前"
    } else if (timeInterval < 60*60*24*30) {
      result = "\(Int(timeInterval/(60*60*24)))天前"
    } else {
      return time
    }
    
    return result!
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
