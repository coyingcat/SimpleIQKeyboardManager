//
//  PersonalData.swift
//  petit
//
//  Created by Jz D on 2020/10/21.
//  Copyright © 2020 swift. All rights reserved.
//

import UIKit


typealias MineDatPieceX = (look : String, name : String, willHide: Bool)


struct MineData{
    
    let look : String
    let name : String
    let willHide: Bool

}
  

struct PersonalData{
    
    static let info = PersonalData()
    
    let items: [MineData]
    let finalIdx: Int
    
    let cellH: CGFloat = 55
    
    init(){
        let sources: [MineDatPieceX] = [ ("mine_member", "开通会员" , true),
                                        ("mine_upload", "我上传的", true),
                                        ("mine_feedback", "意见反馈" , true),
                                        ("mine_settings", "设置" , true)]
        
        
        items = sources.map { (look, name, willHide) -> MineData in
                    return MineData(look: look, name: name, willHide: willHide)
                }
        
        
        finalIdx = sources.count - 1
        
    }
    
    
}




/*
 
 
 [ ("mine_member", "开通会员" , true),
 ("mine_upload", "我上传的", true),
 ("mine_offline_load", "离线下载", true),
 ("mine_share_gift", "分享 app", false),
 ("mine_feedback", "反馈意见" , true),
 ("mine_settings", "设置" , true)]
 
 
 
 */
