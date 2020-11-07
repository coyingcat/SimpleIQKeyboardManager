//
//  Addr.swift
//  musicSheet
//
//  Created by Jz D on 2020/6/19.
//  Copyright © 2020 Jz D. All rights reserved.
//

import Foundation



func addr(){
    withUnsafePointer(to: &UserSetting.shared) {
        print($0)
    }
}
