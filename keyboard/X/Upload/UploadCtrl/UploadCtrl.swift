//
//  UploadContentC.swift
//  petit
//
//  Created by Jz D on 2020/10/27.
//  Copyright © 2020 swift. All rights reserved.
//

import UIKit

import SnapKit

class UploadCtrl: BaseC {
    
    
    struct Metric {
        let tip = "输入您需要默写的内容 This ain't a song for the broken-hearted 这不是一首给伤心人的歌"
        
        let offsetH: CGFloat = 15
        let offsetV: CGFloat = 30
        var firstTapTitle = true
        
        var firstTapContent = true
        
        let placeHolderC = UIColor(rgb: 0xC3C3C3)
        let writeC = UIColor.txt
        let placeHolderTxt = "输入伤心人的歌"
    }
    
    
    var config = Metric()

    var firstTap = true
    
    
    lazy var h: SideHeader = {
        let cao = SideHeader(title: "上传")
        cao.delegate = self
        return cao
    }()
    
    
    lazy var doneTick: UIButton = {
        let b = UIButton()
        b.setTitle("确认", for: .normal)
        b.setTitleColor(UIColor(rgb: 0xC3C3C3), for: .disabled)
        b.setTitleColor(UIColor(rgb: 0x0080FF), for: .normal)
        b.isEnabled = false
        b.titleLabel?.font = UIFont.regular(ofSize: 16)
        return b
    }()
    
    lazy var titleT: FeedbackField = {
        let v = FeedbackField(offset: 15)
        
        v.font = UIFont.semibold(ofSize: 16)
        v.placeholder = config.placeHolderTxt
        v.textColor = config.placeHolderC
        v.clearButtonMode = .whileEditing
        v.delegate = self
        return v
    }()
    
    
    lazy var line: UIView = {
        let l = UIView()
        l.backgroundColor = UIColor(rgb: 0xF4F4F4)
        return l
    }()
    
    
    lazy var inputT: UITextView = {
        let t = UITextView()
        t.delegate = self
        t.textColor = UIColor(rgb: 0xC3C3C3)
        t.font = UIFont.regular(ofSize: 16)
        t.text = config.tip
        let offset: CGFloat = 11
        t.textContainerInset = UIEdgeInsets(top: 15, left: offset, bottom: 15, right: offset)
        return t
    }()
    
    lazy var chB: UIButton = {
        let b = UIButton()
        b.setImage(UIImage(named: "lan_ch_Upload"), for: .normal)
        b.setImage(UIImage(named: "lan_ch_UploadX"), for: .selected)
        return b
    }()
    
    
    lazy var enB: UIButton = {
        let b = UIButton()
        b.setImage(UIImage(named: "lan_en_Upload"), for: .normal)
        b.setImage(UIImage(named: "lan_en_UploadX"), for: .selected)
        return b
    }()
    
    lazy var woXB = -15
    
    var xkbFrame = CGRect.zero
    
    var key: Int?
    
    var bottomConstraint: ConstraintMakerEditable?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        
        doLayout()
        
        
    }
    
    
    
    
    func doLayout(){
        
        
        h.addSubs([doneTick ])
        
        contentView.addSubs([titleT, line, inputT,  chB, enB])
        layout_h()
        doneTick.snp.makeConstraints { (m) in
            m.size.equalTo(CGSize(width: 33, height: 25))
            m.trailing.equalToSuperview().offset(-15)
            m.bottom.equalToSuperview().offset(-15)
        }
        
        titleT.snp.makeConstraints { (m) in
            m.leading.trailing.equalToSuperview()
            m.height.equalTo(33)
            m.top.equalToSuperview().offset(UI.std.contentY + 10)
        }
        
        line.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(15)
            m.trailing.equalToSuperview().offset(15.neg)
            m.top.equalTo(titleT.snp.bottom).offset(8)
            m.height.equalTo(1)
        }
        
        
        inputT.snp.makeConstraints { (m) in
            m.leading.trailing.bottom.equalToSuperview()
            m.top.equalTo(line.snp.bottom)
        }
        
        
        chB.snp.makeConstraints { (m) in
            m.size.equalTo(CGSize(width: 80, height: 35))
            m.leading.equalToSuperview().offset(15)
            bottomConstraint = m.bottom.equalToSuperview().offset(woXB)
        }
        
        enB.snp.makeConstraints { (m) in
            m.top.size.equalTo(chB)
            m.leading.equalTo(chB.snp.trailing).offset(10)
        }
    }


}







extension UploadCtrl: SideHeaderDelegate{
    
    
    func xForce() {
        view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
    
    
    
}



