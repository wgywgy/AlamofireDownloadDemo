//
//  RequestEx.swift
//  ADownloadDemo
//
//  Created by wuguanyu on 16/4/28.
//  Copyright © 2016年 dejauu. All rights reserved.
//

import Foundation
import Alamofire

extension Request {
    public func cancelWithoutLeave() {
        task.cancel()
    }
}
