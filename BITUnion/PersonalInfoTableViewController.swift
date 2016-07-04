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
  

  override func viewDidLoad() {
      super.viewDidLoad()
      performSearch()
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
      "queryusername":"queryusername"
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
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.modifyInformation(topicDetail)
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
    let url = NSURL()
    let imageView = self.view.viewWithTag(1000) as? UIImageView
    imageView?.sd_setImageWithURL(url, placeholderImage: UIImage.init(named: "defaultAvantar"))
    
    let group = self.view.viewWithTag(1001) as? UILabel
    group?.text = "user"
    
    let regisetTime = self.view.viewWithTag(1002) as? UILabel
    regisetTime?.text = ""
    
    let lastLoginTime = self.view.viewWithTag(1003) as? UILabel
    lastLoginTime?.text = ""

  }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
