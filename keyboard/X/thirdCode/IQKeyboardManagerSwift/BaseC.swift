//
//  BaseC.swift
//  IQDropDownTextField
//
//  Created by Jz D on 2020/11/2.
//

import UIKit

class BaseC: UIViewController {

    
    
    var contentView :UIView = {
        let w = UIView()
        w.backgroundColor = .clear
        return w
    }()
    
    
    var firstLoad = true
    
    
    var contentFrame: CGRect{
        get{
            contentView.frame
        }
        set{
            contentView.frame = newValue
        }
    }
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        view.addSubview(contentView)
        configOne()
        
    }
    

 
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if firstLoad{
            contentView.frame = view.frame
            firstLoad = false
        }
        
    }

}



extension UIViewController{
    
    
    var containerFrame: CGRect{
        get{
            if let me = self as? BaseC{
                return me.contentFrame
            }
            else{
                return view.frame
            }
            
        }
        set{
            if let me = self as? BaseC{
                me.contentFrame = newValue
            }
            else{
                view.frame = newValue
            }
        }
        
        
    }
    
    
    
    var virtualView: UIView{
        if let v = self as? BaseC{
            return v.contentView
        }
        else{
            return view
        }
        
    }
    
}
