//
//  FileMonitor.swift
//  FileChangeMonitor
//
//  Created by wuguanyu on 16/4/22.
//  Copyright © 2016年 dejauu. All rights reserved.
//

import UIKit
let fileChangedNotification = "fileChangedNotification"

class FileMonitor: NSObject {
    // Dispatch queue
    //    var dispatchQueue = dispatch_queue_create("FileMonitorQueue", 0)
    var dispatchQueue = dispatch_queue_create("FileMonitorQueue", DISPATCH_QUEUE_SERIAL)
    
    // A source of potential notifications
    var source: dispatch_source_t?
    
    static let sharedInstance = FileMonitor()
    private override init() {}
    
    func startMonitor() {
        // Get the path to the home directory
        let homeDir =
            NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, .UserDomainMask, true).last
        
        // Create a new file descriptor - we need to convert the NSString to a char * i.e. C style string
        let fileDes = open((homeDir?.cStringUsingEncoding(NSASCIIStringEncoding))!, O_EVTONLY)
        
        // Create a dispatch queue - when a file changes the event will be sent to this queue
        //        _dispatchQueue = dispatch_queue_create("FileMonitorQueue", 0);
        
        // Create a GCD source. This will monitor the file descriptor to see if a write command is detected
        // The following options are available
        
        /*!
         * @typedef dispatch_source_vnode_flags_t
         * Type of dispatch_source_vnode flags
         *
         * @constant DISPATCH_VNODE_DELETE
         * The filesystem object was deleted from the namespace.
         *
         * @constant DISPATCH_VNODE_WRITE
         * The filesystem object data changed.
         *
         * @constant DISPATCH_VNODE_EXTEND
         * The filesystem object changed in size.
         *
         * @constant DISPATCH_VNODE_ATTRIB
         * The filesystem object metadata changed.
         *
         * @constant DISPATCH_VNODE_LINK
         * The filesystem object link count changed.
         *
         * @constant DISPATCH_VNODE_RENAME
         * The filesystem object was renamed in the namespace.
         *
         * @constant DISPATCH_VNODE_REVOKE
         * The filesystem object was revoked.
         */
        
        // Write covers - adding a file, renaming a file and deleting a file...
        source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, UInt(fileDes), DISPATCH_VNODE_WRITE, dispatchQueue)
        
        // This block will be called when teh file changes
        dispatch_source_set_event_handler(source!) {
            NSNotificationCenter.defaultCenter().postNotificationName(fileChangedNotification, object: nil)
        }
        
        // When we stop monitoring the file this will be called and it will close the file descriptor
        dispatch_source_set_cancel_handler(source!) {
            close(fileDes)
        }
        
        // Start monitoring the file...
        dispatch_resume(source!)
        
        //...
        
        // When we want to stop monitoring the file we call this
        //dispatch_source_cancel(source);
        
        
        // To recieve a notification about the file change we can use the NSNotificationCenter
        NSNotificationCenter.defaultCenter().addObserverForName(fileChangedNotification, object: nil, queue: nil) { (notification) in
            print("File change detected!")
        }
    }
}
