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

    var every2SReciveBytes: Int64 = 0
    var oldRecivedTime: NSTimeInterval = 0
    
    // notice: It's every time start time, not first start time
    var beginDownloadTime: NSTimeInterval = 0

    dynamic var speedInBytes: Double = 0
    var averageSpeedInBytes: Double = 0
    var lastSpeedInBytes: Double = 0

    var cancelledData: NSData?
    var downloadRequest: Request?
    var downloadStatus = DownloadStatus.Prepare {
        didSet {
            downloadStatusRaw = downloadStatus.rawValue
        }
    }
    
    dynamic var downloadStatusRaw = 0
    var speedTimer: NSTimer?
    
    convenience init(displayName: String, downloadUrlStr: String, savePath: String) {
        self.init()

        self.displayName = displayName
        self.downloadUrlStr = downloadUrlStr
        self.savePath = savePath
        createDate = NSDate()
        
        NSUserDefaults.standardUserDefaults().setObject(downloadUrlStr, forKey: displayName)
        
        speedTimer =
            NSTimer.scheduledTimerWithTimeInterval(0.8, target: self, selector: #selector(DownloadObject.updateSpeed), userInfo: nil, repeats: true)
        speedTimer!.fire()
    }
    
}

// MARK: - DownloadSpeed
extension DownloadObject {
    func updateSpeed() {
        guard downloadStatus == .Executing else { return }
        
        // Calc last 1.4s avg Speed
        if beginDownloadTime == 0 {
            beginDownloadTime = NSDate().timeIntervalSince1970
        } else {
            let interval = NSDate().timeIntervalSince1970 - beginDownloadTime
            averageSpeedInBytes = Double(every2SReciveBytes) / interval
            
            if interval >= 4  {
                beginDownloadTime = NSDate().timeIntervalSince1970
                every2SReciveBytes = 0
            }
        }
        
        speedInBytes = getEMASpeed(avgSpeed: averageSpeedInBytes, lastSpeed: lastSpeedInBytes)
    }
    
    func getEMASpeed(avgSpeed avgSpeed: Double, lastSpeed: Double) -> Double {
        //        http://stackoverflow.com/questions/2779600/how-to-estimate-download-time-remaining-accurately
//        if avgSpeed == 0 { return 0 }
        
        let SMOOTHING_FACTOR = 0.007
        let emaSpeed = SMOOTHING_FACTOR * lastSpeed + (1 - SMOOTHING_FACTOR) * avgSpeed
        return emaSpeed
    }
 
    func calcSpeed(bytes: Int64) {
        if oldRecivedTime == 0 {
            oldRecivedTime = NSDate().timeIntervalSince1970
        } else {
            let interval = NSDate().timeIntervalSince1970 - oldRecivedTime
            
            lastSpeedInBytes = Double(bytes) / interval
            oldRecivedTime = NSDate().timeIntervalSince1970
        }

    }
    
}

// MARK: - DownloadProtocol
extension DownloadObject: DownloadProtocol {
    func defaultDestination() -> Request.DownloadFileDestination {
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

    func startDownloadInQueue() {
        if DownloadObjManager.sharedInstance.currentDownloadItem == nil {
            startDownload()
        } else {
            downloadStatus = .Waiting
        }
    }
    
    func startDownload() {
        DownloadObjManager.sharedInstance.currentDownloadItem = self
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
        
        print("timeOut \(downloadRequest?.request?.timeoutInterval)")
//        downloadRequest!.progress.kind = NSProgressKindFile
        downloadRequest!.progress.kind = NSProgressThroughputKey
        downloadRequest!.progress(downloadProgress) //下载进度
        downloadRequest!.response(completionHandler: downloadResponse) //下载停止响应
//        downloadRequest!.delegate.taskDidCompleteWithError
//        downloadRequest!.delegate.taskDidComplete = { (session: NSURLSession, task: NSURLSessionTask, error: NSError?) in
//                        print("!!!")
//                    }
    }
    
    func getContinueUrlStr() -> String {
        var downloadUrl = NSUserDefaults.standardUserDefaults().objectForKey(displayName!) as! String
        if downloadUrl.characters.count <= 0 {
            downloadUrl = self.downloadUrlStr!
        }
        return downloadUrl
    }
    
    func downloadProgress(bytesRead: Int64, totalBytesRead: Int64, totalBytesExpectedToRead: Int64) {
        reciveDataBytes = totalBytesRead
        totalDataBytes = totalBytesExpectedToRead
        downloadStatus = .Executing
        
        every2SReciveBytes += bytesRead
        calcSpeed(bytesRead)
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
//                BG_Next
            }
        } else {
            print("Successfully downloaded file: \(response)")
        }
    }
    
    func cancelDownload() {
        print("terminate cancel")
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
//        let downloadUrl = NSUserDefaults.standardUserDefaults().objectForKey(displayName!) as! String
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: downloadUrlStr!)
//        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: displayName!)
        
        if cancelledData != nil {
            if let resumeDataDict = try? NSPropertyListSerialization.propertyListWithData(cancelledData!, options: NSPropertyListReadOptions.Immutable, format: nil) as! NSMutableDictionary {
                // print("resumeDataDict \(resumeDataDict)")
                let tmpDataName = resumeDataDict["NSURLSessionResumeInfoTempFileName"] as? String
                if tmpDataName?.characters.count > 0 {
                    let path = NSTemporaryDirectory()
                    let toRemovePath = path.stringByAppendingPathComponent(tmpDataName!)
                    print("toRemovePath: \(toRemovePath)")
                    
                    FileHelper.deleteFile(toRemovePath)
                }
            }
        }

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
