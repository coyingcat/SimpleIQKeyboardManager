//
//  MineCell.swift
//  musicSheet
//
//  Created by Jz D on 2019/8/23.
//  Copyright © 2019 上海莫小臣有限公司. All rights reserved.
//

import UIKit

class MineCell: UITableViewCell {
    
    @IBOutlet weak var mineLook: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var more: UIButton!
    

    
    @IBOutlet weak var line: UIView!
    
    
    func config(_ info: MineData, ip final: Bool){
        mineLook.image = UIImage(named: info.look)
        title.text = info.name
        line.isHidden = final
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
