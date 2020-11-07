//
//  RectAdd.swift
//  musicSheet
//
//  Created by Jz D on 2019/8/26.
//  Copyright © 2019 上海莫小臣有限公司. All rights reserved.
//

import UIKit


extension CGRect{
    
    var end: CGPoint{
        return CGPoint(x: maxX, y: maxY)
    }
    
    var leftBottom: CGPoint{
        return CGPoint(x: minX, y: maxY)
    }
    
    var rightUp: CGPoint{
        return CGPoint(x: maxX, y: minY)
    }
}



struct UI {
    static var height: CGFloat{
        UIScreen.main.bounds.height
    }
    
    
    static var layout: CGRect{
        UIScreen.main.bounds
    }
    
    
    static var width: CGFloat{
        UIScreen.main.bounds.width
    }
    
    static var bigS: Bool{
        UIScreen.main.bounds.width >= 1366
    }
    

    
    static var center: CGPoint{
        CGPoint(x: width * 0.5, y: height * 0.5)
    }
}




struct Split{
    static let width: CGFloat = (UI.width - 80) * 0.5
}





public func * (left: CGFloat, right: Int) -> CGFloat {
    return left * CGFloat(right)
}


public func * (left: Int, right: CGFloat) -> CGFloat {
    return CGFloat(left) * right
}



extension CGFloat{
    var scalar: CGFloat{
        CGFloat(Int(self))
    }
}



extension CGRect{
    func right(x offset: CGFloat) -> CGRect{
        CGRect(origin: CGPoint(x: origin.x + offset, y: origin.y), size: size)
    }
        
    
}
