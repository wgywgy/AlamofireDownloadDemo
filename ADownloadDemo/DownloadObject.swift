//
//  DownloadObject.swift
//  ADownloadDemo
//
//  Created by wuguanyu on 16/3/4.
//  Copyright © 2016年 dejauu. All rights reserved.
//

import UIKit
import Alamofire

enum DownloadState: Int {
    case Prepare
    case Waiting
    case Executing
    case Paused
    case Finished
    case Failed
}

class DownloadObject: NSObject {
    var downloadUrlStr: String?
    var savePath: String?
    var displayName: String?
    var createDate: NSDate?
    dynamic var reciveDataBytes: Int64 = 0
    dynamic var totalDataBytes: Int64 = 0

    var oldRecivedTotalBytes: Int64 = 0
    var oldRecivedTime: NSTimeInterval = 0

    dynamic var speedInBytes: Double = 0

    var cancelledData: NSData?
    var downloadRequest: Request?
    
    let destination =
    Alamofire.Request.suggestedDownloadDestination()
    
    convenience init(downloadUrlStr: String, savePath: String) {
        self.init()

        self.downloadUrlStr = downloadUrlStr
        self.savePath = savePath
        createDate = NSDate()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"cancelTask", name:UIApplicationWillTerminateNotification, object:nil)
    }
    
    func cancelTask() {
        self.cancelDownload()
    }
}

// MARK: - DownloadProtocol
extension DownloadObject: DownloadProtocol {
    typealias DownloadFileDestination = (NSURL, NSHTTPURLResponse) -> NSURL

    func defaultDestination() -> DownloadFileDestination {
        return { temporaryURL, response -> NSURL in
            let donwloadPath =
            NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0].stringByAppendingString("/downloads")

            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(donwloadPath, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription);
            }
            
            let downloadPathUrl = NSURL(fileURLWithPath: donwloadPath).URLByAppendingPathComponent(response.suggestedFilename!)
            print("downloadPathUrl \(downloadPathUrl)")
            return downloadPathUrl
        }
    }

    
    func startDownload() {
        startDownload(downloadUrlStr!, destinationUrl: NSURL(string: savePath!)!)
    }
    
    func startDownload(URLString: String, destinationUrl: NSURL) {
        downloadRequest = NetworkManager.sharedInstance.backgroundManager.download(.GET, URLString, destination: defaultDestination())
        
        downloadRequest!.progress(downloadProgress) //下载进度
        
        downloadRequest!.response(completionHandler: downloadResponse) //下载停止响应
    }
    
    func downloadProgress(bytesRead: Int64, totalBytesRead: Int64, totalBytesExpectedToRead: Int64) {
        self.reciveDataBytes = totalBytesRead
        self.totalDataBytes = totalBytesExpectedToRead
        
        if self.oldRecivedTotalBytes == 0 {
            self.oldRecivedTotalBytes = totalBytesRead
            self.oldRecivedTime = NSDate().timeIntervalSince1970
        } else {
            let interval = NSDate().timeIntervalSince1970 - self.oldRecivedTime
            
            if interval > 0.7 {
                self.speedInBytes =
                    Double(totalBytesRead - self.oldRecivedTotalBytes) / (NSDate().timeIntervalSince1970 - self.oldRecivedTime)
                
                self.oldRecivedTotalBytes = totalBytesRead
                self.oldRecivedTime = NSDate().timeIntervalSince1970
            }
        }
    }
    
    func downloadResponse(request: NSURLRequest?, response: NSHTTPURLResponse?, data: NSData?, error:NSError?) {
        if let error = error {
            if error.code == NSURLErrorCancelled {
                self.cancelledData = data //意外终止的话，把已下载的数据储存起来
                NSUserDefaults.standardUserDefaults().setObject(data, forKey: self.downloadUrlStr!)
            } else {
                print("Failed to download file: \(response) \(error)")
            }
        } else {
            print("Successfully downloaded file: \(response)")
        }
    }
    
    func cancelDownload() {
        downloadRequest?.cancel()
    }
    
    func resumeDownload() {
        if let cancelledData = self.cancelledData {
            downloadRequest = NetworkManager.sharedInstance.backgroundManager.download(cancelledData, destination: defaultDestination())
            
            downloadRequest!.progress(downloadProgress) //下载进度
            
            downloadRequest!.response(completionHandler: downloadResponse) //下载停止响应
        }
    }
}
