//
//  BasicQAView.swift
//  GITRxQAModule
//
//  Created by Keith Lee on 2017/5/23.
//  Copyright © 2017年 git4u.com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BasicQAView: UIView, RxQAViewInterface {

    @IBOutlet weak var qTextfield: UITextField!
    @IBOutlet weak var ansTextfield: UITextField!
    
    var disposeBag: DisposeBag = DisposeBag.init()
    var sourceQAs: Variable<[QA]> = Variable.init([]) {
        didSet {
            bindSources()
        }
    }
    var pickedQA: Variable<QA?> = Variable.init(nil) {
        didSet {
            bindPickedQA()
        }
    }
    
    var qPickerView: UIPickerView! = UIPickerView.init()
    
    override func awakeFromNib() {
        qTextfield.inputView = qPickerView
    }
    
    var questionControlProp: ControlProperty<String?> {
        return qTextfield.rx.text
    }
    
    var answerControlProp: ControlProperty<String?> {
        return ansTextfield.rx.text
    }
    
    func bindSources() {
        sourceQAs.asObservable().subscribe(onNext: { [unowned self]
            _ in
            self.qPickerView.reloadAllComponents()
        })
        .addDisposableTo(disposeBag)
        
        qPickerView.delegate = self
        qPickerView.dataSource = self
        
        let onSelect = qPickerView.rx.itemSelected.asObservable()
        
        onSelect
        .map {[unowned self] (row, _) -> QA? in
            return self.sourceQAs.value[row]
        }
        .debug("picker onSelect")
//        .bind(to: pickedQA)
        .subscribe(onNext: {[unowned self] qa in
            self.pickedQA.value = qa
        })
        .addDisposableTo(disposeBag)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
}

extension BasicQAView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sourceQAs.value.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sourceQAs.value[row].qTitle
    }
    
    
}
