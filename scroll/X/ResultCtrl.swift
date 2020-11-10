//
//  ResultCtrl.swift
//  petit
//
//  Created by Jz D on 2020/10/29.
//  Copyright © 2020 swift. All rights reserved.
//

import UIKit

import SnapKit


class ResultCtrl: UIViewController {
    
    var containerView = UIScrollView()
    
    
    lazy var img = UIImageView()
    
    lazy var tShowD: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        return l
    }()
    
    var key: Int?
    
    
    
    var heightConstraint: ConstraintMakerEditable?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        doLayout()
        refreshUI()
    }
    

    
    func doLayout(){
        fd_prefersNavigationBarHidden = true
        view.backgroundColor = UIColor.white
        
        view.addSubview(containerView)
        
        
        containerView.addSubs([img, tShowD ])
        
        
        containerView.snp.makeConstraints { (m) in
            m.edges.equalToSuperview()
        }
        
        
        img.snp.makeConstraints { (m) in
            m.leading.trailing.top.equalToSuperview()
            heightConstraint = m.height.equalTo(400)
            m.width.equalTo(UI.std.width)
        }
        
        
        tShowD.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(10)
            m.trailing.equalToSuperview().offset(10.neg)
            m.top.equalTo(img.snp.bottom).offset(20)
            m.bottom.equalToSuperview().offset(20.neg)
        }
        
    }

}





extension ResultCtrl{

    func refreshUI(){
        
        
        guard let pic = UIImage(named: "download") else{ return }
        img.image = pic
      
          
            
        let h = UI.std.width * pic.size.height / pic.size.width
            
            
        self.heightConstraint?.constraint.update(offset: h)
            
        self.view.layoutIfNeeded()
        
        tShowD.text = """





        You don’t know how to age
        Your wounds have opened you
        To all the winds
        You think you know yourself
        But all you have is emptiness
        Writing will have only been
        the briefest of mysteries






        Because I want to watch a new sun stain
        the sky with colors I've never seen,
        swaths I can only hint at with words—
        serpentine, tourmaline, silver.
        There is a Chinese symbol she taught me for a word
        that has no word, but I can never remember
        how to draw it, what tone
        to put in my throat when I speak it.
        """
        
        
    }

}
