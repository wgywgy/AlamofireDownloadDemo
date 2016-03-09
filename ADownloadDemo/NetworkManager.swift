//
//  NetworkManager.swift
//  ADownloadDemo
//
//  Created by wuguanyu on 16/3/7.
//  Copyright © 2016年 dejauu. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager: NSObject, NSURLSessionDelegate {
    
    class func defaultConfiguration() -> NSURLSessionConfiguration {
        let bundleId = "com.ex.sarrs"
        let sessionConfig = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(bundleId + ".bg")
        sessionConfig.discretionary = true
        sessionConfig.allowsCellularAccess = false
        return sessionConfig
    }
    
    func defaultSession() -> NSURLSession {
        var token: dispatch_once_t = 0
        
        var session: NSURLSession?
        dispatch_once(&token) {
            session =
                NSURLSession(configuration: NetworkManager.defaultConfiguration(), delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        }
        return session!
    }
    
//    static let sharedInstance = NetworkManager()
    
//    var defaultConfiguration: NSURLSessionConfiguration = {
//        let bundleId = "com.ex.sarrs"
//        let sessionConfig = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(bundleId + ".bg")
//        sessionConfig.discretionary = true
//        sessionConfig.allowsCellularAccess = false
//        return sessionConfig
//    }()

    class var sharedInstance: NetworkManager {
        struct Singleton {
            static let instance = NetworkManager()
        }
        
        return Singleton.instance
    }
    
//    static let sharedManager: Manager = {
//        return Alamofire.Manager(configuration: NetworkManager.defaultConfiguration())
//        return Alamofire.Manager(session: NetworkManager.defaultSession(), delegate: self)
//        return Alamofire.Manager(session: defaultSession(), delegate: Manager.SessionDelegate)
//    }()
    
    lazy var backgroundManager: Alamofire.Manager = {
        return Alamofire.Manager(configuration: NetworkManager.defaultConfiguration())
//        return Alamofire.Manager(session: defaultSession(), delegate: Manager.SessionDelegate)
//        return Alamofire.Manager(session: defaultSession(), delegate: self)
    }()
 
    var backgroundCompletionHandler: (() -> Void)? {
        get {
            return backgroundManager.backgroundCompletionHandler
        }
        set {
            backgroundManager.backgroundCompletionHandler = newValue
        }
    }
}