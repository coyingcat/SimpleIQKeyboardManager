//
//  UserSettings.swift
//  petit
//
//  Created by Jz D on 2020/10/19.
//  Copyright © 2020 Jz D. All rights reserved.
//

import Foundation

struct UsrKey{
    static let time = "UsrKey_time"
 
    
}

struct UserSetting {

    static var shared = UserSetting()
    
    
    
    var currentTime: TimeInterval{
        get {
            if let t = UserDefaults.standard.value(forKey: UsrKey.time) as? Double{
                return t
            }
            return 0
        }
        set(newVal){
            UserDefaults.standard.set(newVal, forKey: UsrKey.time)
        }
    }


}
