//
//  AppDelegate.swift
//  ADownloadDemo
//
//  Created by wuguanyu on 16/3/4.
//  Copyright © 2016年 dejauu. All rights reserved.
//

import UIKit
import Alamofire

enum DataType {
    case AsString(String)
//    case AsClosure((AnyObject?)->String)
    case AsClosure(()->Void)
}

//var dict:Dictionary<String,DataType> = [
//var dict = [
//    "string":DataType.AsString("value")
//    "closure":DataType.AsClosure({(argument:AnyObject) -> String in
//        return "value"
//        }
//    )
//]

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var backIdentifier: UIBackgroundTaskIdentifier?
    
//    var timer = NSTimer()
    
    var downloadNetworkManager: Alamofire.Manager?
    
    var completetionHandler: (() -> Void)?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        downloadNetworkManager = DownloadNetworkManager.sharedInstance.backgroundManager
        let homeDir = FileHelper.document()
        print("Home :\(homeDir)")
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
//        doUpdate()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        print("terminate")
    }

    
    func HandleException(exception: NSException) {
        print("App crashing with exception \(exception)")
    }
    
    func HandleSignal(signal: Int) {
        print("We received a signal: \(signal)")
    }
    
    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
////        DownloadObjManager.sharedInstance.s
//        print("handle compelete.")
//        DownloadObjManager.sharedInstance.startDownloadNext()
//        downloadNetworkManager?.backgroundCompletionHandler = completionHandler
//        DownloadNetworkManager.sharedInstance.backgroundCompletionHandler = completionHandler
        
        
//        let userInfo: [String : AnyObject] = ["sessionIdentifier": identifier, "completionHandler": completionHandler]
//        let userInfo: [String : DataType] = ["sessionIdentifier": DataType.AsString(identifier), "completionHandler": DataType.AsClosure(completionHandler)]
        
//        self.completetionHandler = completionHandler
//        DownloadNetworkManager.sharedInstance.backgroundManager.backgroundCompletionHandler = completionHandler
//        NSNotificationCenter.defaultCenter().postNotificationName("BackgroundSessionUpdated", object: nil, userInfo: nil)
        
//        NSDictionary *userInfo = @{@"sessionIdentifier": identifier,
//            @"completionHandler": completionHandler};
        
    }
 
    func doUpdate () {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let taskID = self.beginBackgroundUpdateTask()
            
            print("do someTask")
//            NSNotificationCenter.defaultCenter().postNotificationName("update UI", object: nil, userInfo: nil)
            
            self.endBackgroundUpdateTask(taskID)
        }
    }
    
    func beginBackgroundUpdateTask() -> UIBackgroundTaskIdentifier {
        return UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({})
    }
    
    func endBackgroundUpdateTask(taskID: UIBackgroundTaskIdentifier) {
        UIApplication.sharedApplication().endBackgroundTask(taskID)
    }

}

