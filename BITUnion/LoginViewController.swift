//
//  ViewController.swift
//  BITUnion
//
//  Created by Yin Shuai on 16/3/9.
//  Copyright © 2016年 Michael. All rights reserved.
//

import Foundation
import UIKit
import Alamofire


class LoginViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
//    loginButtonPressed()
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func loginButtonPressed() {
        let nameTextView = view.viewWithTag(1000) as! UITextField
        let pswTextView = view.viewWithTag(1001) as! UITextField
    
        if let name = nameTextView.text,
          let psw = pswTextView.text  {
          let parameters = ["action":"login",
                        "username":name,
                        "password":psw]

//          UIApplication.sharedApplication().networkActivityIndicatorVisible = true
          
          let urlString = AppData.getPostURLWithlastComponent("bu_logging.php")
          
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
                      AppData.sharedInstance.isLogin = true
                      AppData.sharedInstance.username = jsonDict.objectForKey("username") as! String
                      AppData.sharedInstance.password = psw
                      AppData.sharedInstance.session = jsonDict.objectForKey("session") as! String
                      self.dismissViewControllerAnimated(false, completion: nil)
                    } catch let error as NSError {
                      // failure
                      print("Fetch failed: \(error.localizedDescription)")
                    }
                }
              } else {
                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                  self.showNetWorkError()
                }
                  }
              })
          }
  }
  
 
  
  func logout() {

    let userDefault = NSUserDefaults.standardUserDefaults()
    
    let urlString = "http://out.bitunion.org/open_api/bu_logging.php"
    let parameter = ["action":"logout",
      "username": userDefault.valueForKey("username") as! String,
      "password": userDefault.valueForKey("password") as! String,
      "session" : userDefault.valueForKey("session") as! String]
  
    Alamofire.request(.POST, urlString, parameters: parameter, encoding: .URLEncodedInURL, headers: nil).response { (_, response, data, error) -> Void in
      if let httpResponse = response where httpResponse.statusCode == 200 {
        do {
          let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
          print(jsonDict)
          if jsonDict.valueForKey("result") as! String == "success" {
            print("logout success")
            AppData.sharedInstance.isLogin = false
          }
        } catch {
        }
      } else  {
        print(response?.description)
      }
    }
  }
  
  func showNetWorkError()  {
    let alert = UIAlertController(title: "残念...", message: "can not connect the internet", preferredStyle: .Alert)
    let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
    alert.addAction(action)
    presentViewController(alert, animated: true, completion: nil)
  }
  
  func checkNetWork() -> Bool {
    let netWorkReachabilityManager = NetworkReachabilityManager()
    return (netWorkReachabilityManager?.isReachable)!
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    if segue.identifier == "loginAlready" {
      let controller = segue.destinationViewController as! FourmListViewController
      controller.isLogin = true
      print("back to forum")
    }
  }
}

