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
    func cancelDownload()
    func resumeDownload()
}

extension DownloadProtocol {
}
