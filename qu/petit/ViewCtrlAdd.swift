//
//  ViewCtrlAdd.swift
//  petit
//
//  Created by Jz D on 2020/10/16.
//  Copyright © 2020 Jz D. All rights reserved.
//

import UIKit


import AVFoundation


extension ViewController: StreamingDelegate{
    func streamer(ok finalT: TimeInterval) {
        
    }
    
 
    
    func streamer(dng streamer: Streaming, changedState state: StreamingState) {
        switch state {
        case .playing:
            ()
        case .paused:
            ()
        case .stopped:
            ()
        case .over:
            playB.play()
            isSelected = false
        }
    }
    
    
    
    
    func streamer(fire streamer: Streaming, updatedCurrentTime current: TimeInterval) {
        
          
          UserSetting.shared.currentTime = current
          
          currentTime.text = current.mmSS
          progress.value = Float(current)
        
    }
    
    
    
    
    
    func streamer(_ streamer: Streaming, updatedDuration duration: TimeInterval) {
        config(duration: duration)
    }
    
    
    
}
