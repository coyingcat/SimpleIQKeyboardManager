//
//  Color.swift
//  musicSheet
//
//  Created by Jz D on 2019/8/20.
//  Copyright © 2019 上海莫小臣有限公司. All rights reserved.
//

import UIKit



extension UIColor {
    
    
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
    
    
    
    convenience init(rgb: Int, alpha: CGFloat = 1) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF,
            alpha: alpha
        )
    }
}



extension UIColor{
    
    static let academicSelected = UIColor(named: "AcademicSelected")    //  #C66C86
    static let audioTag = UIColor(named: "AudioTag")    //  #43CAD5
    static let instrumentsTag = UIColor(named: "InstrumentsTag")    //  #FF7584
    
    
    static let main = UIColor(named: "Main")    //  #FF2D55
    static let scoreSwitch: UIColor = UIColor(named: "ScoreSwitch")!  //  #725A7C
    static let textGray = UIColor(named: "TextGray")    //  #666666
    
    
    static let textHeavy = UIColor(named: "TextHeavy")    //  #333333
    static let textLightGray = UIColor(named: "TextLightGray")  //  #999999
    
    
    static let shadow = UIColor(rgb: 0xDBDBDB, alpha: 0.5)
    static let shadowScore = UIColor(rgb: 0xCDCDCD, alpha: 0.5)
    
    
    
    static let newPlayer = UIColor(rgb: 0x925EA8)
}

