//
//  FeedBackController.swift
//  petit
//
//  Created by Jz D on 2020/10/30.
//  Copyright © 2020 swift. All rights reserved.
//

import UIKit

import SnapKit

class FeedBackController: BaseC {

    struct Metric {
        let tips = "请描述您遇到的问题，或是想要给我们的建议"
        
        let offsetH: CGFloat = 15
        let offsetV: CGFloat = 30
        var firstTap = true
        
        var firstTapBottom = true
        
        let txtCol = UIColor(rgb: 0x999999)
        let writeCol = UIColor.txt
    }
    
    
    var config = Metric()
    
    lazy var h: SideHeader = {
        let cao = SideHeader(title: "意见反馈")
        cao.delegate = self
        return cao
    }()
    
    
    
    
    lazy var writes = { () -> UITextView in
        let t = UITextView()
        t.delegate = self
        t.textColor = config.txtCol
        t.font = UIFont.regular(ofSize: 14)
        t.text = config.tips
        
        
        t.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        t.configEight()
        return t
    }()
    
    
    
    lazy var doneB: UIButton = {
        let b = UIButton()
        b.setTitle("提交", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor.main
        b.titleLabel?.font = UIFont.semibold(ofSize: 16)
        return b
    }()
    
    
    lazy var midArea: UIView = {
        let v = UIView()
        v.configEight()
        return v
    }()
    
    
    lazy var contactT: FeedbackField = {
        let v = FeedbackField(offset: 10)
        v.configEight()
        v.font = UIFont.regular(ofSize: 14)
        v.placeholder = "请提供您的联系方式，我们会尽快给您反馈"
        v.textColor = config.txtCol
        v.clearButtonMode = .whileEditing
        v.delegate = self
        return v
    }()
    
    
    lazy var uploadImg: UIImageView = {
        let img = UIImageView(image: UIImage(named: "feedback_upload"))
        img.contentMode = .scaleAspectFill
        img.isUserInteractionEnabled = true
        img.clipsToBounds = true
        return img
    }()
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        doLayout()
        
        
    }
    
    
    
    
    func doLayout(){
        
        configOne()
        
        
        let desp: UILabel = {
            let l = UILabel()
            l.text = "请提供问题的截图或照片（选填）"
            l.textColor = config.txtCol
            l.font = UIFont.regular(ofSize: 14)
            return l
        }()
        
        
        
        
        
        contentView.addSubs([writes, midArea, contactT])
        view.addSubs([doneB])
        layout_h()
        midArea.addSubs([desp, uploadImg])
        
        
        writes.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(config.offsetH)
            m.trailing.equalToSuperview().offset(config.offsetH.neg)
            m.top.equalToSuperview().offset(config.offsetH + UI.std.contentY)
            m.height.equalTo(150)
        }
        
        midArea.snp.makeConstraints { (m) in
            m.leading.trailing.equalTo(writes)
            m.top.equalTo(writes.snp.bottom).offset(config.offsetV)
            m.height.equalTo(140)
        }
        
        let despOffset: CGFloat = 10
        desp.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(despOffset)
            m.trailing.equalToSuperview().offset(despOffset.neg)
            m.top.equalToSuperview().offset(despOffset)
        }
        
        
        uploadImg.snp.makeConstraints { (m) in
            m.leading.equalToSuperview().offset(10)
            m.bottom.equalToSuperview().offset(-18)
            m.size.equalTo(CGSize(width: 70, height: 70))
        }
        
        contactT.snp.makeConstraints { (m) in
            m.leading.trailing.equalTo(writes)
            m.top.equalTo(midArea.snp.bottom).offset(config.offsetV)
            m.height.equalTo(50)
        }
        
        doneB.snp.makeConstraints { (m) in
            m.leading.trailing.bottom.equalToSuperview()
            m.height.equalTo(50)
        }
    }
    


   
    
    
    
    
}






extension FeedBackController: SideHeaderDelegate{
    
    
    func xForce() {
        
        navigationController?.popViewController(animated: true)
    }
    
    
    
    
}








extension FeedBackController: UITextViewDelegate{
    
    
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if config.firstTap{
            config.firstTap = false
            textView.text = nil
            textView.textColor = config.writeCol
        }
        return true
    }
    
    
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == nil || textView.text.count == 0{
            textView.text = config.tips
            config.firstTap = true
            textView.textColor = config.txtCol
        }
    }
    
 
    
}


extension FeedBackController: UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if config.firstTapBottom{
            config.firstTapBottom = false
            textField.text = nil
            textField.textColor = config.writeCol
        }
        return true
    }
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == nil || textField.text?.count == 0{
            config.firstTapBottom = true
            textField.textColor = config.txtCol
        }
    }
    
    
    
}

extension UIView{
    func configEight(){
        corner(4)
        backgroundColor = UIColor(rgb: 0xF9F9F9)
    }
}
