//
//  NetworkManager.swift
//  ADownloadDemo
//
//  Created by wuguanyu on 16/3/7.
//  Copyright © 2016年 dejauu. All rights reserved.
//

import Foundation
import Alamofire

class DownloadNetworkManager {
    
    class func defaultConfiguration() -> NSURLSessionConfiguration {
        let bundleId = "com.ex.sarrs"
        let sessionConfig = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(bundleId + ".bg")
//        sessionConfig.discretionary = true
        sessionConfig.allowsCellularAccess = true
//        sessionConfig.timeoutIntervalForResource = 4
//        sessionConfig.timeoutIntervalForRequest = 3
        return sessionConfig
    }
    
    class var sharedInstance: DownloadNetworkManager {
        struct Singleton {
            static let instance = DownloadNetworkManager()
        }
        
        return Singleton.instance
    }
    
    lazy var backgroundManager: Alamofire.Manager = {
        let sessionDelegate = Manager.SessionDelegate()
        return Alamofire.Manager(configuration: DownloadNetworkManager.defaultConfiguration())
    }()
    
}

extension Manager.SessionDelegate {
    public override class func initialize() {
        Manager.SessionDelegate.reciveData_swizzle()
    }
    
    class func reciveData_swizzle() {
        struct download_swizzleToken {
            static var onceToken : dispatch_once_t = 0
        }
        dispatch_once(&download_swizzleToken.onceToken) {
            let cls: AnyClass! = Manager.SessionDelegate.self
            
            let originalSelector = Selector("URLSession:task:didCompleteWithError:")
            let swizzledSelector = Selector("privateURLSession:task:didCompleteWithError:")
            
            let originalMethod = class_getInstanceMethod(cls, originalSelector)
            let swizzledMethod = class_getInstanceMethod(cls, swizzledSelector)
            
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
    func privateURLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        URLSession(session, task: task, didCompleteWithError: error)

        if let userInfo = error?.userInfo as? [String: AnyObject],
            resumeData = userInfo[NSURLSessionDownloadTaskResumeData] as? NSData {
                print("task Id: \(task.taskIdentifier) des: \(task.taskDescription)")
                NSUserDefaults.standardUserDefaults().setObject(resumeData, forKey: task.originalRequest!.URL!.absoluteString)
                NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}