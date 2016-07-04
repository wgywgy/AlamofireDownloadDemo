//
//  ViewController.swift
//  ADownloadDemo
//
//  Created by wuguanyu on 16/3/4.
//  Copyright © 2016年 dejauu. All rights reserved.
//

import UIKit
import Alamofire

struct Links {
    static let arrayOfLinks: [String] = [
        "http://res.taig.com/installer/TaiGJBreak_244_5174_v.exe",
        "http://upload-images.jianshu.io/upload_images/182346-731485f91ca1e7f9.JPG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240",
        "http://res.taig.com/installer/TaiGJBreak_v245_5266.exe",
        "http://res.taig.com/installer/TaiGJBreak_1210.zip"]
}

class ViewController: UIViewController {

    var downloadObjs = [DownloadObject(displayName: "22", downloadUrlStr: Links.arrayOfLinks[0], savePath: ""),
        DownloadObject(displayName: "23", downloadUrlStr: Links.arrayOfLinks[1], savePath: ""),
        DownloadObject(displayName: "24", downloadUrlStr: Links.arrayOfLinks[2], savePath: ""),
        DownloadObject(displayName: "26", downloadUrlStr: Links.arrayOfLinks[3], savePath: "")]

    @IBOutlet weak var progressView1: UIProgressView!
    @IBOutlet weak var progressView2: UIProgressView!
    @IBOutlet weak var progressView3: UIProgressView!
    @IBOutlet weak var progressView4: UIProgressView!

    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var speedLabel2: UILabel!
    @IBOutlet weak var speedLabel3: UILabel!
    @IBOutlet weak var speedLabel4: UILabel!
    @IBOutlet weak var debugLabel: UILabel!
    
    var speedTimer: NSTimer?
    var oldProgress: Float = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindView()
        FileMonitor.sharedInstance.startMonitor()
        
        DownloadObjManager.sharedInstance.downloadObjs = downloadObjs
        NSSetUncaughtExceptionHandler { exception in
            DownloadObjManager.sharedInstance.cancelAllDownloadObj()
        }
        
//        speedTimer =
//            NSTimer.scheduledTimerWithTimeInterval(0.8, target: self, selector: #selector(ViewController.updateSpeed), userInfo: nil, repeats: true)
//        speedTimer!.fire()

        Alamofire.Manager.SessionDelegate().taskDidComplete = { (session: NSURLSession, task: NSURLSessionTask, error: NSError?) in
        }
        
//        Manager.SessionDelegate().sessionDidFinishEventsForBackgroundURLSession = { (session: NSURLSession) in
//            print("session!!: \(session)")
//        }

//        let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
//        Alamofire.download(.GET, "https://httpbin.org/stream/100", destination: destination)
//            .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
//                print(totalBytesRead)
//                
//                dispatch_async(dispatch_get_main_queue()) {
//                    print("Total bytes read on main queue: \(totalBytesRead)")
//                }
//            }
//            .response { _, _, _, error in
//                if let error = error {
//                    print("Failed with error: \(error)")
//                } else {
//                    print("Downloaded file successfully")
//                }
//        }

        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ViewController.UpdateUI), name:"URLSessionDidFinishEventsForBackgroundURLSession", object:nil)
    }
    
    
//    func callCompletionHandlerForSession(notifation: NSNotification) {
//        let completeHandler = DownloadNetworkManager.sharedInstance.backgroundCompletionHandler
//        if (completeHandler != nil) {
//            completeHandler!()
//        }
//    }
    
    func getDownloadObject(tag: Int) -> DownloadObject {
        if tag < 20  {
            return downloadObjs[0]
        } else if tag < 30  {
            return downloadObjs[1]
        } else if tag < 40 {
            return downloadObjs[2]
        } else {
            return downloadObjs[3]
        }
    }
    
    func UpdateUI() {
//        let index = DownloadObjManager.sharedInstance.downloadObjs.indexOf(DownloadObjManager.sharedInstance.currentDownloadItem!)
//        
//        if index == 3 {
            dispatch_async(dispatch_get_main_queue()) { [weak self]() -> Void in
                self?.view.backgroundColor = UIColor.yellowColor()
//                self?.debugLabel.text = "c: \(index) | all: \(DownloadObjManager.sharedInstance.downloadObjs)"
            }
//        }
//        URLSessionDidFinishEventsForBackgroundURLSession
//         Force Download
//        if index == 1 {
////            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
//            dispatch_async(dispatch_get_main_queue()) { [weak self]() -> Void in
////                guard 
////                let aObj = DownloadObject(displayName: "24", downloadUrlStr: Links.arrayOfLinks[2], savePath: "")
//                let aObj = self!.downloadObjs[3]
//                let aObj = self.downloadObjs[3]
//                aObj.startDownload()
//            }
//        }
        postNotify()
    }
    
    func postNotify() {
        let localNotification = UILocalNotification()
        localNotification.alertBody = "All files have been downloaded"
        UIApplication.sharedApplication().presentLocalNotificationNow(localNotification)
    }
    
    func bindView() {
        let downloadObj1 = downloadObjs[0]
        let timer = RACSignal.interval(0.05, onScheduler: RACScheduler.mainThreadScheduler())

        RACObserve(downloadObj1, keyPath: "reciveDataBytes").sample(timer).subscribeNext { (x) in
            let recivedSize = x as! Float
            if (downloadObj1.totalDataBytes > 0) {
                dispatch_async(dispatch_get_main_queue()) {
                    self.progressView1.progress = recivedSize / Float(downloadObj1.totalDataBytes)
//                    print("\(downloadObj1.downloadRequest?.progress.localizedAdditionalDescription)")
                }
            }
        }
        
//        RACObserve(downloadObj1.downloadRequest?.progress, keyPath: "fractionCompleted").subscribeNext { (x) in
//            let progress = x as! Float
//            self.progressView1.progress = Float(progress)
//        }
        
//        RACObserve(downloadObj1, keyPath: "speedInBytes").subscribeNext { (x) -> Void in
//            dispatch_async(dispatch_get_main_queue()) {
//                self.speedLabel.text = x.doubleValue.KB_S
//            }
//        }
        
        RACObserve(downloadObj1, keyPath: "downloadStatusRaw").subscribeNext { (x) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                let status = DownloadStatus(rawValue: x as! Int)
                if status != .Executing {
                    self.speedLabel.text = self.statusDes(status!)
                }
            }
        }
        
        let downloadObj2 = downloadObjs[1]
        RACObserve(downloadObj2, keyPath: "reciveDataBytes").subscribeNext { (x) -> Void in
            print("reciveDataBytes \(downloadObj2.reciveDataBytes)")
            print("totalDataBytes \(downloadObj2.totalDataBytes)")
            let recivedSize = x as! Float
            if (downloadObj2.totalDataBytes > 0) {
                dispatch_async(dispatch_get_main_queue()) {
                    self.progressView2.progress = recivedSize / Float(downloadObj2.totalDataBytes)
                }
            }
        }
        
        RACObserve(downloadObj2, keyPath: "speedInBytes").subscribeNext { (x) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.speedLabel2.text = x.doubleValue.KB_S
            }
        }

        let downloadObj3 = downloadObjs[2]
        RACObserve(downloadObj3, keyPath: "reciveDataBytes").subscribeNext { (x) -> Void in
            let recivedSize = x as! Float
            if (downloadObj3.totalDataBytes > 0) {
                dispatch_async(dispatch_get_main_queue()) {
                    self.progressView3.progress = recivedSize / Float(downloadObj3.totalDataBytes)
                }
            }
        }
        
        RACObserve(downloadObj3, keyPath: "speedInBytes").subscribeNext { (x) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.speedLabel3.text = x.doubleValue.KB_S
            }
        }
        
        let downloadObj4 = downloadObjs[3]
        RACObserve(downloadObj4, keyPath: "reciveDataBytes").subscribeNext { (x) -> Void in
            let recivedSize = x as! Float
            if (downloadObj4.totalDataBytes > 0) {
                dispatch_async(dispatch_get_main_queue()) {
                    self.progressView4.progress = recivedSize / Float(downloadObj4.totalDataBytes)
                }
            }
        }
        
        RACObserve(downloadObj4, keyPath: "speedInBytes").subscribeNext { (x) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.speedLabel4.text = x.doubleValue.KB_S
            }
        }
    }
    
    @IBAction func start(sender: UIButton) {
        sender.enabled = false
        print("start tag \(sender.tag)")
        let downloadObj = getDownloadObject(sender.tag)
        downloadObj.startDownloadInQueue()
    }
    
    @IBAction func pauseOrContinue(sender: UIButton) {
        print("pause tag \(sender.tag)")
        let downloadObj = getDownloadObject(sender.tag)
   
        sender.setTitle("Pause", forState: .Normal)
        sender.setTitle("Conti", forState: .Selected)
        if sender.selected {
            sender.selected = false
            downloadObj.resumeDownload()
        } else {
            sender.selected = true
            downloadObj.cancelDownload()
        }
    }
    
    @IBAction func cancel(sender: UIButton) {
        let downloadObj = getDownloadObject(sender.tag)
        downloadObj.cancelDownload()
    }
    
    @IBAction func carshApp(sender: AnyObject) {
        NSException(name: "App Crash", reason: "Simulate", userInfo: nil).raise()
    }
    
    @IBAction func startAll(sender: AnyObject) {
        DownloadObjManager.sharedInstance.startAll()
    }
    
    func statusDes(status: DownloadStatus) -> String {
        switch status {
        case .Failed:
            return "Fail"
        case .Finished:
            return "Finished"
        case .Paused:
            return "Paused"
        case .Executing:
            return "Downloading"
        case .Deleted:
            return "Deleted"
        default:
            return "Unknown"
        }
    }

    @IBAction func DelTask(sender: AnyObject) {
        let downloadObj = getDownloadObject(sender.tag)
        downloadObj.delete()
    }
    
//    func updateSpeed() {
//        if oldProgress == 0 {
//            oldProgress = self.progressView1.progress
//        } else {
//           let speed = (oldProgress - self.progressView1.progress) / 0.8
//        }
//    }
}
