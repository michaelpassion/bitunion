//
//  TopDetailViewController.swift
//  BITUnion
//
//  Created by Yin Shuai on 16/3/15.
//  Copyright © 2016年 Michael. All rights reserved.
//

import UIKit
import Alamofire
import MJRefresh
import DTCoreText
import SDWebImage


class TopicDetailTableViewController: UITableViewController
   {
  
  let getImageRootURL = "http://out.bitunion.org/"
  var tid:String = ""
  var from = 0
  var totalNum = 0
  var topicDetailList:NSMutableArray = []
  let header = MJRefreshNormalHeader()
  var topicTitle = ""
  
  let footer = MJRefreshAutoStateFooter()
  var request: Alamofire.Request?
  var lastActionLink:NSURL?
  
  var mediaPlayers:NSMutableSet = []
  var firstPullDown =  true

  override func viewDidLoad() {
    registCell()
    tableView.tableFooterView = UIView(frame: CGRect.zero)
    tableView.tableHeaderView = UIView(frame: CGRect.zero)
  
    header.setRefreshingTarget(self, refreshingAction: #selector(TopicDetailTableViewController.headerRefresh))
    self.tableView.mj_header = header
    
    header.lastUpdatedTimeLabel.hidden = true
    footer.setRefreshingTarget(self, refreshingAction: #selector(TopicDetailTableViewController.footerRefresh))
    self.tableView.mj_footer = footer

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 88.0;
  
    footer.setTitle("", forState: .Idle)
    
    self.tableView.mj_header.beginRefreshing()
    self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
  }
  
  
  
  func headerRefresh() {
    if !firstPullDown {
      self.tableView.mj_header.endRefreshing()
      return
    } else {
      performSearch()
      firstPullDown = false
    }
  }
  
  func footerRefresh() {
    from += 20
    if from < totalNum {
      performSearch()
    } else {
      from -= 20
      print("no more result")
      self.tableView.mj_footer.endRefreshingWithNoMoreData()
    }
  }
  
  func registCell() {
    let cellNib = UINib(nibName: "TopicDetailTextViewCell", bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: "TopicDetailTextViewCellIdentifier")
    
  }
  
  func performSearch() {

    let parameters = [
      "action":"post",
      "username":AppData.sharedInstance.username,
      "session":AppData.sharedInstance.session,
      "tid":tid,
      "from":from,
      "to": (from + 20)
    ]
    
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    let urlString = AppData.getPostURLWithlastComponent("bu_post.php")
    self.request = Alamofire.request(
      .POST,
      urlString,
      parameters: parameters as? [String : AnyObject],
      encoding: .JSON,
      headers: nil)
    
    weak var weakself = self
    if let _ = request {
      self.request!.response {
        (request, response, data, error) -> Void in
        if let httpResponse = response
        where httpResponse.statusCode == 200 {
          if let data = data {
            do {
              let topicDetail:NSDictionary =  try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
              
              if AppData.checkIfSessionTimeOut(topicDetail) {
                AppData.updateSession() { () in
                weakself?.performSearch()
                }
              }
              
              if let objects = topicDetail.objectForKey("postlist") as? NSArray {
                let range = NSRange(location: self.from, length: objects.count)
                weakself?.topicDetailList.insertObjects(objects as [AnyObject], atIndexes: NSIndexSet(indexesInRange: range))
              } else {
                
              }
              
              dispatch_async(dispatch_get_main_queue()) {
                weakself!.tableView.reloadData()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                if self.tableView.mj_header.state == MJRefreshState.Refreshing {
                  weakself!.header.endRefreshing()
                } else if self.tableView.mj_footer.state == MJRefreshState.Refreshing {
                  weakself!.footer.endRefreshing()
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

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated);
    self.request?.cancel()
    self.request = nil
    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
  }
  


  override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    return indexPath
  }
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  // MARK: - TableView DataSource
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return topicDetailList.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("TopicDetailTextViewCellIdentifier", forIndexPath: indexPath) as! TopicDetailTextViewCell
    
    cell.message.shouldDrawLinks = false
    cell.message.shouldDrawImages = false
    cell.message.delegate = cell
    cell.tid = self.tid
    cell.topicText = self.topicTitle
    let dict = topicDetailList[indexPath.row] as! NSDictionary
    
    let index = indexPath.row
    if index == 0 {
      cell.floor.text = "楼主"
    } else {
      cell.floor.text = "\(index + 1) 楼"
    }
    
    configureCell(cell, withDictionary: dict)
    return cell
  }
  
  func stringByDecodeingHTMLCharacters(htmlText: String) -> NSAttributedString? {
    let attributedOptions: [NSObject: AnyObject] = [
      NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
      NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
    ]
    if let encodedData = htmlText.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), let attributedstring = try? NSAttributedString(data: encodedData, options: attributedOptions as! [String: AnyObject], documentAttributes: nil) {
      return attributedstring
    }
      return nil
  }
  
  
  func configureCell(cell: UITableViewCell, withDictionary dict:NSDictionary) {
    let cell = cell as! TopicDetailTextViewCell
    
    cell.quote.userInteractionEnabled = true
    cell.quote.backgroundColor = UIColor.clearColor()
    cell.quote.layer.cornerRadius = 4
    cell.quote.layer.borderWidth = 1
    
    cell.quote.layer.borderColor = self.view.tintColor.CGColor
    // author string
    cell.author.text = dict.objectForKey("author")?.stringByRemovingPercentEncoding
    
    // message string
    let message = dict.objectForKey("message")?.stringByRemovingPercentEncoding

    if let msg:String = message! {
      
      let width = self.view.bounds.width / 2
    
      var sEncode = msg.stringByReplacingOccurrencesOfString("+", withString: " ").stringByReplacingOccurrencesOfString("border=\"0\" width=\"100%\" cellspacing=\"1\" cellpadding=\"10\"", withString: "").stringByReplacingOccurrencesOfString("bgcolor=\"BORDERCOLOR\"", withString: "style=\"color: grey ;text-align:left; border-left: solid grey; font-family:Arial, Helvetica, sans-serif\"").stringByReplacingOccurrencesOfString("<img src=\"../images/smilies/", withString: "<img src=\"").stringByReplacingOccurrencesOfString("src=\"../images/bz/", withString: "src=\"").stringByReplacingOccurrencesOfString("<img src=\"http", withString: "<img  style=\"width:\(width)px; height:\(width)px align:center\" src=\"http").stringByReplacingOccurrencesOfString("<tr><td>&nbsp;&nbsp;引用:</td></tr>", withString: "").stringByReplacingOccurrencesOfString("<td", withString: "<td style=\"padding-left:15px\" ")
      
      
      if let attachment = dict["attachment"] as? String where
        attachment != "<null>" {
        let imageURL = getImageRootURL + attachment
        let imgTag = "<center><img  style=\"width:\(width)px; height:\(width)px align:center \" src=\"" + imageURL + "\"> </center>"

        sEncode.appendContentsOf(imgTag)
  
      }
    
      
      let readmePath = NSBundle.mainBundle().bundlePath
      let maxImageSize = CGSizeMake(self.view.bounds.size.width - 20.0, self.view.bounds.size.height - 20.0)
      var options:[String : AnyObject] = [NSTextSizeMultiplierDocumentOption : 1.2,
                                          DTMaxImageSize: NSValue.init(CGSize: maxImageSize),
                                          DTDefaultFontFamily: "Helvetica Neue"]
      options[NSBaseURLDocumentOption] = NSURL.fileURLWithPath(readmePath)
      
      
        var sDecode = ""
        if let htmlString = sEncode.stringByRemovingPercentEncoding {
          sDecode = htmlString
        } else {
          sDecode = sEncode
        }
        let data = sDecode.dataUsingEncoding(NSUTF8StringEncoding)
      
      cell.message.attributedString = NSAttributedString(HTMLData: data, options: options, documentAttributes: nil)
      }
  
      //time string
      let timeString = dict.objectForKey("dateline") as! String
      let date = NSDate(timeIntervalSince1970: Double(timeString)!)
      var text = (date.description) as NSString
      text = text.substringWithRange(NSMakeRange(0, 19))
      cell.posttime.text = text as String
      
      // avatar
      cell.avatar.layer.cornerRadius = cell.avatar.frame.width / 2
      cell.avatar.layer.masksToBounds = true
    
      if let avatarURL = dict.objectForKey("avatar") as? String {
        let a = avatarURL.stringByRemovingPercentEncoding
        let b = a?.stringByReplacingOccurrencesOfString("+", withString: " ")
        if let array = b?.componentsSeparatedByString(" ") {
          // if user has a avatar
          if array.count > 1,
            let src = array[1] as? String{
            let range = Range<String.Index>(start: src.startIndex.advancedBy(5),
                                            end: src.endIndex.advancedBy(-1))
            let url = getImageRootURL + src.substringWithRange(range)
            let image = UIImage(named: "defaultAvantar.gif")
            let URL = NSURL(string: url)
             cell.avatar.sd_setImageWithURL(URL, placeholderImage: image, options: .ProgressiveDownload)

          } else if array.count == 1{
            dispatch_async(dispatch_get_main_queue(), {
              let image = UIImage(named: "defaultAvantar.gif")
                cell.avatar?.image = image
            })
          }
        }
      }
  }
  
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "REPLYTOAUTHOR" {
      let navigationController = segue.destinationViewController as! UINavigationController
      let controller = navigationController.viewControllers.first as! PostNewTopicViewController
      controller.title = "回复"
      controller.topicText = self.topicTitle
      controller.isReplay = true
      controller.tid = self.tid
    }
  }
  
}