//
//  FileHelper.swift
//  ADownloadDemo
//
//  Created by wuguanyu on 16/3/17.
//  Copyright © 2016年 dejauu. All rights reserved.
//

import UIKit

class FileHelper: NSObject {
    
    class func document() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths[0]
    }

    class func downloadFolder() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return (paths[0] as NSString).stringByAppendingPathComponent("downloads")
    }

    class func deleteFile(pathStr: String) {
        let fileManager = NSFileManager.defaultManager()
        do {
            try fileManager.removeItemAtPath(pathStr)
        } catch let error {
            print("error \(error)")
        }
    }
}
