//
//  DownloadObject.swift
//  ADownloadDemo
//
//  Created by wuguanyu on 16/3/4.
//  Copyright © 2016年 dejauu. All rights reserved.
//

import UIKit
import Alamofire

enum DownloadStatus: Int {
    case Prepare, Waiting, Executing, Paused, Finished, Failed, Deleted
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
    var downloadStatus = DownloadStatus.Prepare {
        didSet {
            downloadStatusRaw = downloadStatus.rawValue
        }
    }
    
    dynamic var downloadStatusRaw = 0
    
    convenience init(displayName: String, downloadUrlStr: String, savePath: String) {
        self.init()

        self.displayName = displayName
        self.downloadUrlStr = downloadUrlStr
        self.savePath = savePath
        createDate = NSDate()
        
        NSUserDefaults.standardUserDefaults().setObject(downloadUrlStr, forKey: displayName)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(DownloadObject.cancelDownload), name:UIApplicationWillTerminateNotification, object:nil)
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
            print("!!downloadPathUrl \(downloadPathUrl)")
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: response.URL!.absoluteString)
            
            self.downloadStatus = .Finished
            return downloadPathUrl
        }
    }

    func startDownload() {
        // 根据DisplayName找到Url, Url 找 NSData
        let downloadUrl = getContinueUrlStr()
        
        if cancelledData == nil {
            cancelledData = NSUserDefaults.standardUserDefaults().objectForKey(downloadUrl) as? NSData
        }

        if cancelledData != nil {
            print("start by data length: \(cancelledData?.length)")
            downloadRequest = DownloadNetworkManager.sharedInstance.backgroundManager.download(cancelledData!, destination: defaultDestination())
        } else {
            print("start by url")
//            startDownload(downloadUrlStr!, destinationUrl: NSURL(string: savePath!)!)
            downloadRequest = DownloadNetworkManager.sharedInstance.backgroundManager.download(.GET, downloadUrlStr!, destination: defaultDestination())
        }
        downloadRequest!.progress(downloadProgress) //下载进度
        downloadRequest!.response(completionHandler: downloadResponse) //下载停止响应

    }
    
    func getContinueUrlStr() -> String {
        var downloadUrl = NSUserDefaults.standardUserDefaults().objectForKey(displayName!) as! String
        if downloadUrl.characters.count <= 0 {
            downloadUrl = self.downloadUrlStr!
        }
        return downloadUrl
    }
    
    func downloadProgress(bytesRead: Int64, totalBytesRead: Int64, totalBytesExpectedToRead: Int64) {
        self.reciveDataBytes = totalBytesRead
        self.totalDataBytes = totalBytesExpectedToRead
        downloadStatus = .Executing
        
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
                cancelledData = data
//                NSUserDefaults.standardUserDefaults().setObject(data, forKey: request!.URL!.absoluteString)
                downloadStatus = .Paused
            } else {
                downloadStatus = .Failed
                print("Failed to download file: \(response) \(error)")
            }
        } else {
            print("Successfully downloaded file: \(response)")
        }
    }
    
    func cancelDownload() {
        downloadRequest?.cancel()
        downloadStatus = .Paused
    }
    
    func resumeDownload() {
        if let cancelledData = self.cancelledData {
            downloadRequest = DownloadNetworkManager.sharedInstance.backgroundManager.download(cancelledData, destination: defaultDestination())
            
            downloadRequest!.progress(downloadProgress) //下载进度
            
            downloadRequest!.response(completionHandler: downloadResponse) //下载停止响应
        }
    }
    
    func delete() {
        downloadRequest?.cancelWithoutLeave()
        downloadStatus = .Deleted
        DownloadCleaner.cleanTmpDir()
//        let downloadUrl = NSUserDefaults.standardUserDefaults().objectForKey(displayName!) as! String
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: downloadUrlStr!)
//        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: displayName!)
    }
    
    func processResumeData(resumeData: NSData, urlStr: String) -> NSData {
        let resumeDataDict = try? NSPropertyListSerialization.propertyListWithData(resumeData, options: NSPropertyListReadOptions.Immutable, format: nil) as! NSMutableDictionary
        
        //2
        let newResumeRequest = NSMutableURLRequest(URL: NSURL(string: urlStr)!)
        newResumeRequest.addValue("bytes=\(resumeDataDict!["NSURLSessionResumeBytesReceived"])", forHTTPHeaderField: "Range")
        
        //3
        let newResumeRequestData = NSKeyedArchiver.archivedDataWithRootObject(newResumeRequest)
        
        //4
        resumeDataDict!.setObject(newResumeRequestData, forKey: "NSURLSessionResumeCurrentRequest")
        resumeDataDict!.setObject("NewRemoteURL", forKey: "NSURLSessionResumeCurrentRequest")
        
        //5
        let newResumeData: NSData? = try? NSPropertyListSerialization.dataWithPropertyList(resumeDataDict!, format: NSPropertyListFormat.XMLFormat_v1_0, options: 0)
        return newResumeData!
    }

}
