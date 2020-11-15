//
//  Camera_add.swift
//  petit
//
//  Created by Jz D on 2020/11/4.
//  Copyright © 2020 swift. All rights reserved.
//

import UIKit






extension ZLCustomCamera{
    

    
    @objc
    func rotateRhs() {
        guard let img = takedImage else {
            return
        }
        let radian = CGFloat.pi * 0.5
        angleX += 1
        
        takedImageView.transform = CGAffineTransform(rotationAngle: radian * angleX)
        if Int(angleX) % 2 == 1{
            takedImageView.frame = view.bounds
            
        }
        else{
            let ratio = img.size.height / img.size.width
            let w = UI.std.width
            let h = w * ratio
            takedImageView.frame = CGRect(x: 0, y: 0, width: w, height: h)
            
        }
        takedImageView.center = CGPoint(x: UI.std.width * 0.5, y: UI.std.height * 0.5)
    }
    
    
    
    
}
