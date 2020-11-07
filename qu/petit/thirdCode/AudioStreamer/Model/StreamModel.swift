//
//  StreamModel.swift
//  petit
//
//  Created by Jz D on 2020/10/20.
//  Copyright © 2020 Jz D. All rights reserved.
//

import Foundation







struct AudioRecord{
    
    // 重复
    var countStdRepeat = 0
    var howMany = 0
    var toClimb = true
    
    
    
    
    var current = 0
    
    
    
    // pause , 停顿
    var pauseWork = false
    var currentMoment = Date()
    
    var stdPauseT: TimeInterval = 1
    
    mutating
    func twoTime(hit isH: Bool){
        if isH{
            countStdRepeat = 1
        }
        else{
            countStdRepeat = 0
        }
    }
    
    
    mutating
    func threeTime(hit isH: Bool){
        if isH{
            countStdRepeat = 2
        }
        else{
            countStdRepeat = 0
        }
    }
    
    
    mutating
    func doPause(at index: Int){
        current = index + 1
        toClimb = true
        howMany = 0
        currentMoment = Date()
        pauseWork = true
    }
    
    
    
    mutating
    func delay(two isH: Bool){
        if isH{
            stdPauseT = 2
        }
        else{
            stdPauseT = 1
        }
    }
    
    
   
    mutating
    func delay(three isH: Bool){
        if isH{
            stdPauseT = 3
        }
        else{
            stdPauseT = 1
        }
    }
    
}
