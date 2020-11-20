//
//  UploadContent_proxy.swift
//  petit
//
//  Created by Jz D on 2020/11/1.
//  Copyright © 2020 swift. All rights reserved.
//

import Foundation




extension UploadCtrl: UITextViewDelegate{
    
    
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if config.firstTapTitle{
            config.firstTapTitle = false
            textView.text = nil
            textView.textColor = config.writeC
        }
        return true
    }
    
    
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == nil || textView.text.count == 0{
            bottomRecover()
        }
        UIView.animate(withDuration: 0.3) {
            self.bottomConstraint?.constraint.update(offset: self.woXB)
            self.contentView.layoutIfNeeded()
        }
    }
    
 
    
    func bottomRecover(){
        inputT.text = config.tip
        config.firstTapTitle = true
        inputT.textColor = config.placeHolderC
    }
    
}


extension UploadCtrl: UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if config.firstTapContent{
            config.firstTapContent = false
            textField.text = nil
            textField.textColor = config.writeC
        }
        return true
    }
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == nil || textField.text?.count == 0{
            config.firstTapContent = true
            textField.textColor = config.placeHolderC
        }
    }
    
    
    
}


