//
//  DownloadCleaner.swift
//  ADownloadDemo
//
//  Created by wuguanyu on 16/4/22.
//  Copyright © 2016年 dejauu. All rights reserved.
//

import UIKit

class DownloadCleaner: NSObject {
    
    class func cleanNSCachesDir() {
        let cachePath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!
        let subPath = "/com.apple.nsurlsessiond/Downloads/com.dejauu.ADownloadDemo"
        do {
            let array = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(cachePath.stringByAppendingPathComponent(subPath))
            for string in array {
//                let toRemovePath = /com.apple.nsurlsessiond/Downloads/com.xxx.xxx/%@",  string
                let toRemovePath = "/com.apple.nsurlsessiond/Downloads/com.dejauu.ADownloadDemo/" + string
                try NSFileManager.defaultManager().removeItemAtPath(toRemovePath)
            }
        } catch let err {
            print("cleanNSCachesDir err: \(err)")
        }
    }
    
    class func cleanTmpDir() {
        let path = NSTemporaryDirectory()
        do {
            let array = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(path)
            for string in array {
                let toRemovePath = path.stringByAppendingPathComponent(string)
                print("toRemovePath \(toRemovePath)")
                try NSFileManager.defaultManager().removeItemAtPath(toRemovePath)
            }
        } catch let err {
            print("cleanTmpDir err: \(err)")
        }
    }
}

extension String {
    func stringByAppendingPathComponent(pathComponent: String) -> String {
        return (self as NSString).stringByAppendingPathComponent(pathComponent)
    }
}