//
//  AppData.swift
//  BITUnion
//
//  Created by Yin Shuai on 16/3/12.
//  Copyright © 2016年 Michael. All rights reserved.
//

import Foundation
import MBProgressHUD
import Alamofire

class AppData {
  static let sharedInstance = AppData()
  var isLogin = false
  var session = ""
  var username = ""
  var password = ""
  var isOutofSchool = true
  var test = 0
  var showImage = true
  
  
 class func checkIfSessionTimeOut(dict: NSDictionary) -> Bool {
    return dict.isEqualToDictionary(["msg":"IP+logged",
      "result": "fail"])
  }
  
  class func getPostURLWithlastComponent(last: String) -> String {
    let inSchool = "http://www.bitunion.org/open_api/"
    let outofSchool = "http://out.bitunion.org/open_api/"
    return AppData.sharedInstance.isOutofSchool ? outofSchool + last : inSchool + last
  }
  class func updateSession(completionBlock:()->()) {
    
    let parameters = ["action":"login",
                      "username":AppData.sharedInstance.username,
                      "password":AppData.sharedInstance.password]
    
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true

    let hud = MBProgressHUD(window:UIApplication.sharedApplication().keyWindow)
    hud.mode = .AnnularDeterminate
    hud.labelText = "重新登录中"
    hud.show(true)
    
    
    let urlString = AppData.getPostURLWithlastComponent("bu_logging.php")
    Alamofire.request(.POST, urlString, parameters: parameters, encoding: .JSON, headers: nil).response(completionHandler: { (urlRequest, response, data, error) -> Void in
      UIApplication.sharedApplication().networkActivityIndicatorVisible = false
      if let httpResponse = response where
        httpResponse.statusCode == 200 {
        if let data = data {
          do {
            let jsonDict = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            
            AppData.sharedInstance.isLogin = true
            AppData.sharedInstance.session = jsonDict.objectForKey("session") as! String
            completionBlock()
          } catch {
            print("json serial error")
          }
        }
      } else {
        dispatch_async(dispatch_get_main_queue()) {
          
          let alert = UIAlertController(title: "残念...", message: "can not connect the internet", preferredStyle: .Alert)
          let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
          alert.addAction(action)
          UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
        }
      }
//      hud.hide(true)
    })
  }

}
