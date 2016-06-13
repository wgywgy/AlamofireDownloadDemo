//
//  DownloadObjManager.swift
//  ADownloadDemo
//
//  Created by wuguanyu on 16/5/17.
//  Copyright © 2016年 dejauu. All rights reserved.
//

import UIKit

class DownloadObjManager: NSObject {
    static let sharedInstance = DownloadObjManager()
    
    dynamic var currentDownloadItem: DownloadObject? {
        willSet {
            if newValue == nil {
                cleanObservers()
            } else if newValue != currentDownloadItem {
                setupObservers(forItem: newValue!)
            }
        }
    }
    
    var downloadObjs = [DownloadObject]()
    
    var disposeList = [RACDisposable]()
    
    override init() {
        super.init()
//        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(DownloadObjManager.BgDownloadNext),
//                                                         name:"URLSessionDidFinishEventsForBackgroundURLSession", object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(DownloadObjManager.BgDownloadNext),
                                                         name:"BG_Next", object:nil)

    }
    
    func addADownloadObj(downloadObj: DownloadObject) {
        downloadObjs.append(downloadObj)
    }
    
    func cancelAllDownloadObj() {
        currentDownloadItem?.cancelDownload()
    }
    
    func startAll() {
        downloadObjs.forEach { $0.startDownloadInQueue() }
    }
    
    private func setupObservers(forItem item: DownloadObject) {
        let d0 = RACObserve(item, keyPath: "downloadStatusRaw").subscribeNext { (x) -> Void in
            
            let status = DownloadStatus(rawValue: x as! Int)!
            switch status {
            case .Paused:
                self.startDownloadNext()
//            case .Failed:
//                self.startDownloadNext()
//                return
//            case .Finished:
//                self.startDownloadNext()
//                return
            default:
                return
            }
        }
        disposeList.append(d0)
    }
    
    func BgDownloadNext() {
        if currentDownloadItem != nil {
            currentDownloadItem = nil
        }

        for item in downloadObjs {
            if item.downloadStatus == .Waiting {
                item.startDownloadInQueue()
                return
            }
        }
    }

    func startDownloadNext() {
        if currentDownloadItem != nil {
            currentDownloadItem = nil
        }
        for item in downloadObjs {
            if item.downloadStatus == .Waiting {
                item.startDownloadInQueue()
                return
            }
        }
    }

    private func cleanObservers() {
        disposeList.forEach { $0.dispose() }
        disposeList.removeAll(keepCapacity: true)
    }

}
