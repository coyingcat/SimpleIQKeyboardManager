//
//  ComeController.swift
//  petit
//
//  Created by Jz D on 2020/11/15.
//  Copyright © 2020 swift. All rights reserved.
//

import UIKit

class ComeController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    
    
    @IBAction func takePic(_ sender: Any) {
        
        
        self.showDetailViewController(ZLCustomCamera(), sender: nil)
        
        
    }
    
    

}
