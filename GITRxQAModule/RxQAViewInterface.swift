//
//  RxQAViewInterface.swift
//  GITRxQAModule
//
//  Created by keith.lee on 2017/5/22.
//  Copyright © 2017年 git4u.com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol RxQAViewInterface {
    
    /// 用以綁定viewModel裡的selectedQA var
    var controlProp: ControlProperty<String> { get }
    var pickerView: UIPickerView! { get set }
    
    func bindSelectedQA(selectedQAVar: Variable<QA?>)
    func bindSourceQAs(sourceQAs qasVar: Variable<[QA]>)
}


protocol RxQAViewControllerInterface {
    var qaViews: [RxQAViewInterface] { get }
    func bindingAllSelectedQAs()
    func bindingAllSourceQAs()
}


protocol RxQAViewControllerViewModelInterface {
    
}
