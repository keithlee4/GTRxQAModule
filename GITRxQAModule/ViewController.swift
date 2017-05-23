//
//  ViewController.swift
//  GITRxQAModule
//
//  Created by keith.lee on 2017/5/22.
//  Copyright © 2017年 git4u.com. All rights reserved.
//

import UIKit
import RxSwift

class QAViewModel: RxCustomizableQAViewControllerViewModelInterface {
    let module = QAModuleManager.moduleInUse
    
    func pick(qContainerIdx idx: Int, qa: QA) {
        module.handler.pick(idx: idx, QA: qa)
    }
    
    func pickedQAVar(ofQContainerIdx idx: Int) -> Variable<QA?> {
        return module.handler.pickedQA(ofIdx:idx)
    }
    
    func addCustomizedQA(qa: QA, toQContainerIdx qIdx: Int) {
        module.handler.addCustomizedQA(qa: qa, toIdxQContainer: qIdx)
    }
    
    func qas(forQContainerIdx idx: Int) -> Variable<[QA]> {
        let qasVar = module.handler.curQAsVarOfSourceIdx(idx: idx)!
        return qasVar
    }
}

class ViewController: UIViewController, RxCustomizableQAViewControllerInterface {
    typealias ViewModelType = QAViewModel
    typealias QAViewType = CustomizableQAView
    
    var viewModel = QAViewModel.init()
    
    @IBOutlet weak var qaBaseView1: UIView!
    @IBOutlet weak var qaBaseView2: UIView!
    @IBOutlet weak var qaBaseView3: UIView!
    var qaContainer1: CustomizableQAView = Bundle.main.loadNibNamed("CustomizableQAView", owner: nil, options: nil)![0] as! CustomizableQAView
    var qaContainer2: CustomizableQAView = Bundle.main.loadNibNamed("CustomizableQAView", owner: nil, options: nil)![0] as! CustomizableQAView
    var qaContainer3: CustomizableQAView = Bundle.main.loadNibNamed("CustomizableQAView", owner: nil, options: nil)![0] as! CustomizableQAView
    
    var qaViews: [CustomizableQAView] {
        return [qaContainer1, qaContainer2, qaContainer3 ]
    }

    var disposeBag = DisposeBag.init()
    
    func appendQAViews(){
        qaContainer1.frame = qaBaseView1.bounds
        qaBaseView1.addSubview(qaContainer1)
        
        qaContainer2.frame = qaBaseView2.bounds
        qaBaseView2.addSubview(qaContainer2)
        
        qaContainer3.frame = qaBaseView3.bounds
        qaBaseView3.addSubview(qaContainer3)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        appendQAViews()
        
        viewModel.getNewQAs()
            .debug("Get New QAS")
        .subscribe(onNext:{ [unowned self] in
            self.bindingAllSourceQAs()
            self.bindingAllSelectedQAs()
            self.bindAddCustomizedQATrigger()
        })
        .addDisposableTo(disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        qaContainer1.frame = qaBaseView1.bounds
//        qaBaseView1.addSubview(qaContainer1)
        
        qaContainer2.frame = qaBaseView2.bounds
//        qaBaseView2.addSubview(qaContainer2)
        
        qaContainer3.frame = qaBaseView3.bounds
//        qaBaseView3.addSubview(qaContainer3)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func startAddCustomizedQA(forIdx idx: Int) {
        print("yoyoyo~~~ ready to show some customized qa flow of idx \(idx)~~~~")
        //FIXME: JUST FOR TEST
        let cusQA = QA.init(qNo: QA.customizedQAId, qTitle: "Cus QA \(idx)")
        viewModel.addCustomizedQA(qa: cusQA, toQContainerIdx: idx)
    }
    
}

