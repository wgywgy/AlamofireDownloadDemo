//
//  Downloader.swift
//  ADownloadDemo
//
//  Created by wuguanyu on 16/3/4.
//  Copyright © 2016年 dejauu. All rights reserved.
//

import Foundation

protocol DownloadProtocol {
    func startDownload()
    func startDownload(URLString: String, destinationUrl: NSURL)
    func cancelDownload()
    func resumeDownload()
}

extension DownloadProtocol {
//    func startDownload() {
//        startDownload(downloadUrlStr!, destinationUrl: NSURL(string: savePath!)!)
//    }
}
