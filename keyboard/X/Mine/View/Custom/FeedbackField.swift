//
//  FeedbackField.swift
//  petit
//
//  Created by Jz D on 2020/11/1.
//  Copyright © 2020 swift. All rights reserved.
//

import UIKit

class FeedbackField: UITextField {
    
    
    
    
    
    let hOffset: CGFloat
    
    
    init(offset hV: CGFloat) {
        hOffset = hV
        super.init(frame: .zero)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        var text = super.textRect(forBounds: bounds)
        text.origin.x += hOffset
        text.size.width = text.size.width - hOffset * 2
        return text
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var editing = super.editingRect(forBounds: bounds)
        editing.origin.x += hOffset
        editing.size.width = editing.size.width - hOffset * 2
        return editing
    }
}
