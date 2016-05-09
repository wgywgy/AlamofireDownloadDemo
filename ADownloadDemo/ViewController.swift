//
//  ViewController.swift
//  ADownloadDemo
//
//  Created by wuguanyu on 16/3/4.
//  Copyright © 2016年 dejauu. All rights reserved.
//

import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindView()
        FileMonitor.sharedInstance.startMonitor()
    }
    
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
    
    func bindView() {
        let downloadObj1 = downloadObjs[0]
        RACObserve(downloadObj1, keyPath: "reciveDataBytes").subscribeNext { (x) in
//            let recivedSize = x as! Float
            if (downloadObj1.totalDataBytes > 0) {
                let progress = Float((downloadObj1.downloadRequest?.progress.completedUnitCount)!) / Float((downloadObj1.downloadRequest?.progress.totalUnitCount)!)
                dispatch_async(dispatch_get_main_queue()) {
//                    self.progressView1.progress = recivedSize / Float(downloadObj1.totalDataBytes)
                    self.progressView1.progress = progress
                    print("\(downloadObj1.downloadRequest?.progress.localizedDescription)")
                }
            }
        }
        
//        RACObserve(downloadObj1.downloadRequest, keyPath: "").subscribeNext { (x) in
//            let recivedSize = x as! Float
//            if (downloadObj1.totalDataBytes > 0) {
//                dispatch_async(dispatch_get_main_queue()) {
//                    self.progressView1.progress = recivedSize / Float(downloadObj1.totalDataBytes)
//                }
//            }
//        }

        
        RACObserve(downloadObj1, keyPath: "speedInBytes").subscribeNext { (x) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.speedLabel.text = self.presentSpeedString(x.floatValue)
            }
        }
        
        RACObserve(downloadObj1, keyPath: "downloadStatusRaw").subscribeNext { (x) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                let status = DownloadStatus(rawValue: x as! Int)
                if status != .Executing {
                    self.speedLabel.text = self.statusDes(status!)
                }
            }
        }
        
//        let signal = RACSignal.interval(60, onScheduler: RACScheduler!)
//        RACSignal *updateEventSignal = [[[RACSignal
//            interval:(60 * minutesToNextHour)]
//            take:1]
//            concat:[RACSignal interval:3600]];
        
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
                self.speedLabel2.text = self.presentSpeedString(x.floatValue)
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
                self.speedLabel3.text = self.presentSpeedString(x.floatValue)
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
                self.speedLabel4.text = self.presentSpeedString(x.floatValue)
            }
        }
    }
    
    @IBAction func start(sender: UIButton) {
        sender.enabled = false
        print("start tag \(sender.tag)")
        let downloadObj = getDownloadObject(sender.tag)
        downloadObj.startDownload()
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
    
    func presentSpeedString(speed: Float) -> String {
        if Float(speed) / 1024 / 1024 > 1 {
            return NSString(format: "%.2fM/s", Float(speed) / 1024 / 1024) as String
        } else {
            return NSString(format: "%.1fK/s", Float(speed) / 1024) as String
        }
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
    
}
