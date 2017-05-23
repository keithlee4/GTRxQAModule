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

protocol RxQAViewInterface: NSObjectProtocol {
    /// 用以綁定viewModel裡的selectedQA var
    var questionControlProp: ControlProperty<String?> { get }
    var answerControlProp: ControlProperty<String?> { get }
    var qPickerView: UIPickerView! { get set }
    
    var sourceQAs: Variable<[QA]> { get set }
    var pickedQA: Variable<QA?> { get set }
    func bindSources()
    func bindPickedQA()
    
    var disposeBag: DisposeBag { get set }
}

extension RxQAViewInterface {
    func bindPickedQA() {
        pickedQA.asObservable().map { (optionalQA) -> String? in
            guard let qa = optionalQA else {
                return nil
            }
            
            return qa.qTitle
        }.debug("update picked title")
        .bind(to: questionControlProp)
        .addDisposableTo(disposeBag)
        
        pickedQA.asObservable().map { (optionalQA) -> String? in
            guard let qa = optionalQA else {
                return nil
            }
            
            return qa.ansContent
        }
        .debug("update picked content")
        .bind(to: answerControlProp)
        .addDisposableTo(disposeBag)
        
        answerControlProp.asObservable()
            .filter({[unowned self] (_) -> Bool in
                return self.pickedQA.value != nil
            })
            .subscribe(onNext: { [unowned self]
                text in
                self.pickedQA.value!.ansContent = text
            })
            .addDisposableTo(disposeBag)

    }
}


//MARK: - View Interface

protocol RxCustomizableQAViewInterface: RxQAViewInterface {
    var cutomizedQATriggerObserv: Observable<()>? { get set }
}

//MARK: - View Controller Interface

protocol RxQAViewControllerInterface: NSObjectProtocol {
    associatedtype ViewModelType: RxQAViewControllerViewModelInterface
    associatedtype QAViewType: RxQAViewInterface
    
    var viewModel: ViewModelType { get set }
    var qaViews: [QAViewType] { get }
    var disposeBag: DisposeBag { get set }
    
    func bindingAllSelectedQAs()
    func bindingAllSourceQAs()
}

extension RxQAViewControllerInterface {
    func bindingAllSourceQAs() {
        for (idx, qaView) in qaViews.enumerated() {
            let qasVar = viewModel.qas(forQContainerIdx: idx)
            qaView.sourceQAs = qasVar
        }
    }
    
    func bindingAllSelectedQAs() {
        for (idx, qaView) in qaViews.enumerated() {
            let pickedQAVar = viewModel.pickedQAVar(ofQContainerIdx: idx)
            qaView.pickedQA = pickedQAVar
        }
    }
}

protocol RxCustomizableQAViewControllerInterface: RxQAViewControllerInterface {
    func addCustomizedQA(qa: QA, qIdx idx: Int)
    func bindAddCustomizedQATrigger()
    
    //This should imple by subclass
    func startAddCustomizedQA(forIdx idx: Int)
}

extension RxCustomizableQAViewControllerInterface where ViewModelType : RxCustomizableQAViewControllerViewModelInterface, QAViewType : RxCustomizableQAViewInterface {
    func addCustomizedQA(qa: QA, qIdx idx: Int) {
        viewModel.addCustomizedQA(qa: qa, toQContainerIdx: idx)
    }
    
}

extension RxCustomizableQAViewControllerInterface where QAViewType : RxCustomizableQAViewInterface {
    func bindAddCustomizedQATrigger() {
        for (idx, qaView) in qaViews.enumerated() {
            guard let triggerObserv = qaView.cutomizedQATriggerObserv else { continue }
            triggerObserv
            .debounce(0.2, scheduler: MainScheduler.asyncInstance)
            .subscribe(
                onNext: { [unowned self] _ in
                    self.startAddCustomizedQA(forIdx: idx)
                }
            )
            .addDisposableTo(disposeBag)
        }
    }
}

//MARK: - View Model Interface

protocol RxQAViewControllerViewModelInterface {
    func pick(qContainerIdx idx: Int, qa: QA)
    func qas(forQContainerIdx idx: Int) -> Variable<[QA]>
    func pickedQAVar(ofQContainerIdx idx: Int) -> Variable<QA?>
    func getNewQAs() -> Observable<()>
}

extension RxQAViewControllerViewModelInterface {
    func getNewQAs() -> Observable<()> {
        return QAModuleManager.moduleInUse.getNewQAsAndStore()
    }
}

protocol RxCustomizableQAViewControllerViewModelInterface: RxQAViewControllerViewModelInterface {
    func addCustomizedQA(qa: QA, toQContainerIdx qIdx: Int)
}
