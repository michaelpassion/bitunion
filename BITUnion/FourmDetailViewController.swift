//
//  FourmDetailViewController.swift
//  BITUnion
//
//  Created by Yin Shuai on 16/3/13.
//  Copyright © 2016年 Michael. All rights reserved.
//

import UIKit
import Alamofire
import MJRefresh
import MBProgressHUD

class FourmDetailViewController: UITableViewController {
  var fid:String = ""
  var fourmDetailList:NSMutableArray = []
  var from:Int = 0
  let header = MJRefreshNormalHeader()
  let footer = MJRefreshBackNormalFooter()
  var request: Alamofire.Request?
  var pulldown = true
  
  @IBOutlet weak var navigationBar: UINavigationItem!
  let MAXRequestNumber = 20

  override func viewDidLoad() {
    super.viewDidLoad()

    registCell()
    
    header.setRefreshingTarget(self, refreshingAction: #selector(FourmDetailViewController.headerRefresh))
    self.tableView.mj_header = header
    header.lastUpdatedTimeLabel.hidden = true
    
    footer.setRefreshingTarget(self, refreshingAction: #selector(FourmDetailViewController.footerRefresh))
    self.tableView.mj_footer = footer
    headerRefresh()
    tableView.tableFooterView = UIView(frame: CGRect.zero)
    self.tableView.mj_header.beginRefreshing()
    
    self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
  }
  
  func headerRefresh() {
    from = 0
    pulldown = true
    performSearch()
  }
  
  func footerRefresh() {
    let size = fourmDetailList.count
    from = size
    pulldown = false
    performSearch()
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
      "to": (from + MAXRequestNumber)
    ]
     UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    
      self.request?.cancel()
      let urlString = AppData.getPostURLWithlastComponent("bu_thread.php")
        self.request = Alamofire.request(.POST, urlString,
        parameters: parameters as? [String : AnyObject],
        encoding: .JSON,
        headers: nil)
    
      weak var weakself = self
    
      self.request!.response { (request, response, data, error) -> Void in
        if let httpResponse = response where httpResponse.statusCode == 200 {
          if let data = data {
            do {
              let forumDetail =  try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
              
              if AppData.checkIfSessionTimeOut(forumDetail as! NSDictionary) {
                AppData.updateSession() {() in
                  weakself?.performSearch()
                }
              }
              
              if let newDataArray = forumDetail.objectForKey("threadlist") as? NSArray {
                if self.pulldown {
                  weakself?.fourmDetailList.removeAllObjects()
                  let indexSet = NSIndexSet(indexesInRange: NSRange(location: self.from, length: newDataArray.count))
                  weakself?.fourmDetailList.insertObjects(newDataArray as [AnyObject], atIndexes: indexSet)

                  
//                  // Cause the server didn't provide a way to request totaly new data, so I did a trick to remove the duplicate
//                  if let duplicateRow = weakself?.fourmDetailList.indexOfObject(newDataArray.firstObject!) where duplicateRow != NSNotFound {
//                    let indexSet = NSIndexSet(indexesInRange: NSRange(location: self.from, length: duplicateRow ))
//                    let arr = newDataArray.objectsAtIndexes(indexSet)
//                     weakself?.fourmDetailList.insertObjects(arr as [AnyObject], atIndexes: indexSet)
//                  } else {
//                    let indexSet = NSIndexSet(indexesInRange: NSRange(location: self.from, length: newDataArray.count))
//                    
//                    weakself?.fourmDetailList.insertObjects(newDataArray as [AnyObject], atIndexes: indexSet)
//                  }
                  
                } else {
                  
                  let indexSet = NSIndexSet(indexesInRange: NSRange(location: self.from, length: newDataArray.count))
                  
                  weakself?.fourmDetailList.insertObjects(newDataArray as [AnyObject], atIndexes: indexSet)
                
                }
              
                dispatch_async(dispatch_get_main_queue()) {
                  UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                  weakself?.tableView.reloadData()
      
                  if weakself!.tableView.mj_header.state == MJRefreshState.Refreshing {
                    weakself!.header.endRefreshing()
                  } else if weakself!.tableView.mj_footer.state == MJRefreshState.Refreshing {
                    weakself!.footer.endRefreshing()
                  }
                }
              }
            } catch {
              print(error)
            }
          }
      }
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    performSegueWithIdentifier("TopicDetail", sender: tableView.cellForRowAtIndexPath(indexPath))
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
    let cell = cell as! FourmTopicCell

    let tmp = dict.objectForKey("subject")!.stringByRemovingPercentEncoding!!.stringByReplacingOccurrencesOfString("+", withString: " ")
    let htmlString = "<span style=\"font-family: system; font-size: 16\">\(tmp)</span>"
    let encodedData = htmlString.dataUsingEncoding(NSUnicodeStringEncoding)!
    let attributedOptions = [
      NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
      NSFontAttributeName: UIFontTextStyleTitle1]
    
    do {
      let attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
      cell.topicLabel?.attributedText = attributedString
      cell.topicLabel.font.fontWithSize(21)
    } catch _ {
      print("cannot create attribted String")
    }
   
//    cell.topicLabel?.attributedText = NSAttributedString(string:htmlString)
    cell.authorLabel.text = dict.objectForKey("author")?.stringByRemovingPercentEncoding
    let replies = dict.objectForKey("replies") as! String
    let views = dict.objectForKey("views") as! String
    cell.reviewAndFeedLabel.text = "\(replies)/\(views)"
    
    // time 
    let timeString = dict.objectForKey("dateline") as! String
    let date = NSDate(timeIntervalSince1970: Double(timeString)!)
    var text = (date.description) as NSString
    text = text.substringWithRange(NSMakeRange(0, 10))
    cell.postTimeLabel.text = text as String
    
    cell.tid = dict.objectForKey("tid") as! String
    cell.totalNum = Int(replies)!

  }
  
  override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 66
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "TopicDetail" {
      let controller = segue.destinationViewController as! TopicDetailTableViewController
      
      let cell = sender as! FourmTopicCell
      controller.tid = cell.tid
      controller.totalNum = cell.totalNum
      controller.topicTitle = cell.topicLabel.text!
    } else if segue.identifier == "PostNewThread" {
      let navigationController = segue.destinationViewController as! UINavigationController
      let controller = navigationController.viewControllers.first as! PostNewTopicViewController
      controller.fid = self.fid
    }
  }
  
  
  
//  deinit {
//    print("I'm here to deinit")
//    self.request?.cancel()
//    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//  }
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated);
    self.request?.cancel()
    self.request = nil
    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    
    print("viewwilldisapper")
  }
}
