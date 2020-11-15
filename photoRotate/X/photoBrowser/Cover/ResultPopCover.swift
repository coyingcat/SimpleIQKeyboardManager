//
//  ResultPopCover.swift
//  petit
//
//  Created by Jz D on 2020/11/4.
//  Copyright © 2020 swift. All rights reserved.
//

import UIKit


struct PopFreestore {
    let head: String
    let content: String
    let bLhs: String
    
    let bRhs: String
    
    
}


extension PopFreestore{
    
    static let camera = PopFreestore(head: "确定要退出吗", content: "现在记录一下默写结果，复习的时候会更方便哦！", bLhs: "记录一下", bRhs: "确认退出")
    
    static let upload_data_segment = PopFreestore(head: "要开始默写吗", content: "我们将根据您输入的内容进行默写，内容已被保存在“我上传的”中", bLhs: "不了，先保存", bRhs: "开始默写")
    
    
    static let pIssue_data_segment = PopFreestore(head: "课文内容有问题？", content: "请将错误的地方告诉我们，我们会尽快核实改正，感谢您的反馈", bLhs: "不用了", bRhs: "反馈一下")
}


enum ResultPopCoverSrc{
    case dft, upload
}



class ResultPopCover: UIView {

    let src: PopFreestore
    
    lazy var title: UILabel = {
        let l = UILabel()
        l.text = src.head
        l.font = .regular(ofSize: 18)
        l.textColor = UIColor(rgb: 0x404248)
        l.backgroundColor = UIColor.white
        l.textAlignment = .left
        return l
    }()
    
    
    lazy var content: UILabel = {
        let l = UILabel()
        l.text = src.content
        l.font = .regular(ofSize: 16)
        l.textColor = UIColor(rgb: 0x404248)
        l.backgroundColor = UIColor.white
        l.textAlignment = .left
        l.numberOfLines = 2
        return l
    }()
    
    
    lazy var recordB: UIButton = {
        let b = UIButton()
        b.setTitle(src.bLhs, for: .normal)
        b.titleLabel?.font = UIFont.regular(ofSize: 14)
        b.setTitleColor(UIColor(rgb: 0x0080FF), for: .normal)
        return b
    }()
    
    
    lazy var quitB: UIButton = {
        let b = UIButton()
        b.setTitle(src.bRhs, for: .normal)
        b.titleLabel?.font = UIFont.regular(ofSize: 14)
        b.setTitleColor(UIColor(rgb: 0x0080FF), for: .normal)
        return b
    }()
    
    
    
    let source: ResultPopCoverSrc
    
    
    init(free store: PopFreestore, from ref: ResultPopCoverSrc = .dft) {
        source = ref
        src = store
        super.init(frame: CGRect.zero)
        
        
        corner(4)
        isHidden = true
        
        doFrame()
    }
    
    
    
    func doFrame(){
        backgroundColor = UIColor.white
        let offset: CGFloat = 25
        addSubs([title, content, recordB,
                 quitB ])
        
        title.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(offset)
            m.trailing.equalToSuperview().offset(offset.neg)
            m.top.equalToSuperview().offset(20)
        }
        
        content.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(offset)
            m.trailing.equalToSuperview().offset(offset.neg)
            m.top.equalTo(title.snp.bottom).offset(offset)
            m.height.equalTo(50)
        }
        
        let bHigh: CGFloat = 24
        var bWidth: CGFloat = 60
        if case ResultPopCoverSrc.upload = source{
            bWidth = 85
        }
        
        quitB.snp.makeConstraints { (m) in
            m.size.equalTo(CGSize(width: bWidth, height: 24))
            m.trailing.equalToSuperview().offset(-23)
            m.bottom.equalToSuperview().offset(-18)
        }
        
        
        
        recordB.snp.makeConstraints { (m) in
            m.size.equalTo(CGSize(width: bWidth, height: bHigh))
            m.bottom.equalTo(quitB)
            m.trailing.equalTo(quitB.snp.leading).offset(-21)
            
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    

}
