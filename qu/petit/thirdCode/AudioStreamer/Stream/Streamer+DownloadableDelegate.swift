//
//  Streamer+DownloadingDelegate.swift
//  AudioStreamer
//
//  Created by Syed Haris Ali on 6/5/18.
//  Copyright © 2018 Ausome Apps LLC. All rights reserved.
//

import Foundation
import os.log

extension Streamer {
    
  

    
    public func download(didReceiveData data: Data) {
        os_log("%@ - %d", log: Streamer.logger, type: .debug, #function, #line)

        guard let parser = parser else {
            os_log("Expected parser, bail...", log: Streamer.logger, type: .error)
            return
        }
        
        /// Parse the incoming audio into packets
        do {
            try parser.parse(data: data)
        } catch {
            os_log("Failed to parse: %@", log: Streamer.logger, type: .error, error.localizedDescription)
        }
        
        /// Once there's enough data to start producing packets we can use the data format
        if reader == nil, let _ = parser.dataFormat {
            do {
                reader = try Reader(parser: parser, readFormat: readFormat)
            } catch {
                os_log("Failed to create reader: %@", log: Streamer.logger, type: .error, error.localizedDescription)
            }
        }
        
        /// Update the progress UI
        DispatchQueue.main.async {
            [weak self] in
            
            
            // Check if we have the duration
            self?.handleDurationUpdate()
        }
    }
    
}
