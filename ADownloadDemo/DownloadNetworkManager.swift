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
        sessionConfig.allowsCellularAccess = true
        sessionConfig.sessionSendsLaunchEvents = true
//        sessionConfig.timeoutIntervalForResource = 4
        
        return sessionConfig
    }
    
    static let sharedInstance = DownloadNetworkManager()
    
    lazy var backgroundManager: Alamofire.Manager = {

//        sessionDelegate.downloadTaskDidResumeAtOffset = { (session: NSURLSession, task: NSURLSessionDownloadTask, fileOffset: Int64, expectedTotalBytes: Int64) in
//            print("fileOffset: \(fileOffset)")
//            print("expectedTotalBytes: \(expectedTotalBytes)")
//        }
        return Alamofire.Manager(configuration: DownloadNetworkManager.defaultConfiguration())
    }()
    
//    var backgroundCompletionHandler: (() -> Void)? {
//        get {
//            return backgroundManager.backgroundCompletionHandler
//        }
//        set {
//            backgroundManager.backgroundCompletionHandler = newValue
//        }
//    }
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
            
            let originalSelector = #selector(NSURLSessionTaskDelegate.URLSession(_:task:didCompleteWithError:))
            let swizzledSelector = #selector(Manager.SessionDelegate.privateURLSession(_:task:didCompleteWithError:))
            
            let originalMethod = class_getInstanceMethod(cls, originalSelector)
            let swizzledMethod = class_getInstanceMethod(cls, swizzledSelector)
            
            method_exchangeImplementations(originalMethod, swizzledMethod)
            
            let oSelector = #selector(Manager.SessionDelegate.URLSessionDidFinishEventsForBackgroundURLSession(_:))
            let nSelector = #selector(Manager.SessionDelegate.privateURLSessionDidFinishEventsForBackgroundURLSession(_:))
//
            let oSelectorMethod = class_getInstanceMethod(cls, oSelector)
            let nSelectorMethod = class_getInstanceMethod(cls, nSelector)
            
            method_exchangeImplementations(oSelectorMethod, nSelectorMethod)
//            DownloadTaskDelegate
            
//            let oSelector = #selector(Manager.SessionDelegate.URLSession(_:downloadTask:didFinishDownloadingToURL:))
//            let nSelector = #selector(Manager.SessionDelegate.privateURLSession(_:downloadTask:didFinishDownloadingToURL:))
//            
//            let oSelectorMethod = class_getInstanceMethod(cls, oSelector)
//            let nSelectorMethod = class_getInstanceMethod(cls, nSelector)
//            
//            method_exchangeImplementations(oSelectorMethod, nSelectorMethod)


        }
        
    }
    
    func privateURLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        URLSession(session, task: task, didCompleteWithError: error)

        if let userInfo = error?.userInfo as? [String: AnyObject],
            resumeData = userInfo[NSURLSessionDownloadTaskResumeData] as? NSData {
            print("task Id: \(task.taskIdentifier) des: \(task.taskDescription)")
            let url = userInfo[NSURLErrorFailingURLStringErrorKey] as! String
            NSUserDefaults.standardUserDefaults().setObject(resumeData, forKey: url)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
//    public func privateURLSession(
//        session: NSURLSession,
//        downloadTask: NSURLSessionDownloadTask,
//        didFinishDownloadingToURL location: NSURL)
//    {
//        URLSession(session, downloadTask: downloadTask, didFinishDownloadingToURL: location)
////        DownloadObjManager.sharedInstance.startDownloadNext()
//    }
    
    public func privateURLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        URLSessionDidFinishEventsForBackgroundURLSession(session)
        
        print("finish bg")
        NSNotificationCenter.defaultCenter().postNotificationName("URLSessionDidFinishEventsForBackgroundURLSession",
                                                                  object: session.configuration.identifier, userInfo: nil)

//        DownloadObjManager.sharedInstance.startDownloadNext()
    }
}