//
//  AppData.swift
//  BITUnion
//
//  Created by Yin Shuai on 16/3/12.
//  Copyright © 2016年 Michael. All rights reserved.
//

import Foundation

class AppData {
  static let sharedInstance = AppData()
  var isLogin = false
  var session = ""
  var username = ""
  var password = ""
}
