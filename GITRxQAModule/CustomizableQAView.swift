//
//  CustomizableQAView.swift
//  GITRxQAModule
//
//  Created by keith.lee on 2017/5/23.
//  Copyright © 2017年 git4u.com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CustomizableQAView: BasicQAView, RxCustomizableQAViewInterface {
    @IBOutlet weak var cusBtn: UIButton!
    
    var cutomizedQATriggerObserv: Observable<()>? 
    override func awakeFromNib() {
        super.awakeFromNib()
        cutomizedQATriggerObserv = cusBtn.rx.tap.asObservable()
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
