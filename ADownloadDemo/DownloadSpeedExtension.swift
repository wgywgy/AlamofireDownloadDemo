//
//  DownloadSpeedExtension.swift
//  ADownloadDemo
//
//  Created by wuguanyu on 16/6/13.
//  Copyright © 2016年 dejauu. All rights reserved.
//

import Foundation

extension Double {
    var KB_S: String {
        let MB: Double = 1024 * 1024
        if self / MB > 1 {
            return String(format: "%.2fM/s", self / MB)
        } else {
            return String(format: "%.1fk/s", self / 1024)
        }
//        let speed = NSByteCountFormatter.stringFromByteCount(Int64(self), countStyle: NSByteCountFormatterCountStyle.File)
//        return String(format: "%@/s", speed)
    }
}