//
//  Handler.swift
//  GITRxQAModule
//
//  Created by keith.lee on 2017/5/22.
//  Copyright © 2017年 git4u.com. All rights reserved.
//

import Foundation
import RxSwift

///基本處理QA的協定
protocol RxQAHandlerInterface {
    
    /// 轉換二維時的陣列寬度
    var numOfQContainers: Int { get }
    
    /// 對應QA List的picked QA
    var pickedQA: [Int : Variable<QA?>] { get set }
    func pickedQA(ofIdx idx: Int) -> Variable<QA?>
    
    var originQAs: [QA] { get set }
    
    /// 選取特定idx的QA
    ///
    /// - Parameters:
    ///   - idx:
    ///   - QA:
    /// - Returns:
    mutating func pick(idx: Int, QA: QA)
    
    /// 重置選取的清單
    ///
    /// - Returns:
    mutating func resetPickedQA()
    
    /// 將一維由fetcher取得的清單，轉換為二維
    ///
    /// - Parameter qas:
    /// - Returns:
    mutating func parse(qasFromFetcher qas: [QA]) -> [Variable<[QA]>]
}

///可以自定義問題的處理協定
protocol RxCustomizableQAHandlerInterface {
    /// 將自定義問題加入問題清單
    ///
    /// - Parameters:
    ///   - qa:
    ///   - idx:
    mutating func addCustomizedQA(qa: QA, toIdxQContainer idx: Int)
}

class RxBasicQAHandler: RxQAHandlerInterface {
    internal var originQAs: [QA] = []
    
    var numOfQContainers: Int = 3
    var pickedQA: [Int : Variable<QA?>] = [ : ]
    var disposeBag: DisposeBag = DisposeBag.init()
    
    func pickedQA(ofIdx idx: Int) -> Variable<QA?> {
        return pickedQA[idx] ?? Variable.init(nil)
    }
    
    func pick(idx: Int, QA: QA) {
        pickedQA[idx]?.value = QA
    }
    
    func resetPickedQA() {
        pickedQA = [ : ]
        for i in 0 ..< numOfQContainers {
            pickedQA[i] = Variable.init(nil)
        }
        
        observPickedQAVar()
    }
    
    /// 將所有picked QA Var綁定到更新行為上
    func observPickedQAVar() {
        for (idx, qaVar) in pickedQA {
            qaVar.asObservable()
            .debug("picked qa var changed")
            .subscribe(onNext: { [unowned self] _ in
                //一但選取特定的問題後，所有非該idx的二維陣列裡的qa清單都要重新過濾
                for i in 0 ..< self.numOfQContainers {
                    guard i != idx else {
                        continue
                    }
                    
                    self.filterQAsList(sourceIdx: i)
                }
            })
            .addDisposableTo(disposeBag)
        }
    }
    
    func parse(qasFromFetcher qas: [QA]) -> [Variable<[QA]>] {
        resetPickedQA()
        originQAs = qas
        
        var result : [Variable<[QA]>] = []
        for _ in 0 ..< numOfQContainers {
            let qasVar = Variable.init(qas)
            result.append(qasVar)
        }
        
        return result
    }
    
    func curQAsVarOfSourceIdx(idx: Int) -> Variable<[QA]>? {
        return QAModuleManager.moduleInUse.storage.qasList?[idx]
    }
    
    //找到目前Storage問題清單裡對應idx裡的QAs Value
    private func curQAsOfSourceIdx(idx: Int) -> [QA]? {
        return curQAsVarOfSourceIdx(idx: idx)?.value
    }

    /// 更新目前對應idx的問題清單
    ///
    /// - Parameters:
    ///   - idx:
    ///   - newQAs:
    private func updateCurQas(sourceIdx idx: Int, toQAs newQAs: [QA]) {
        guard let nowQAVarOfSourceIdx = QAModuleManager.moduleInUse.storage.qasList?[idx] else {
            print("Warning: cannot find idx \(idx) in source idx array, won't do any update")
            return
        }
        
        nowQAVarOfSourceIdx.value = newQAs
    }
    
    
    /// 將原本的所有題目加上對應Idx的自定義題目合併，並且過濾掉所有選擇的問題，最後給予此idx qasVar新的qas value.
    ///
    /// - Parameter sourceIdx:
    private func filterQAsList(sourceIdx: Int) {
        var originSource = originQAs
        
        //如果有自定義題目，加在原本的source裡一併參考
        if let nowQAsOfSourceIdx = curQAsOfSourceIdx(idx: sourceIdx) {
            let customizedQAs = nowQAsOfSourceIdx.filter({ (qa) -> Bool in
                return qa.isCustomized
            })
            
            originSource += customizedQAs
        }
        
        for (idx, varQA) in pickedQA {
            guard let qa = varQA.value else {
                continue
            }
            
            guard sourceIdx != idx else {
                //跳過屬於自己選取的問題
                continue
            }
            
            guard let pickedQAIdxInOrigin = originSource.index(of: qa) else {
                print("Warning: - Get some qa but unable to filter out")
                print("Sources: \(originSource)")
                print("target: \(qa.qNo) \(qa.qTitle)")
                continue
            }
            
            originSource.remove(at: pickedQAIdxInOrigin)
        }
        
        let updatedSource = originSource
        updateCurQas(sourceIdx: sourceIdx, toQAs: updatedSource)
    }
}


class RxCustomizableQAHandler: RxBasicQAHandler, RxCustomizableQAHandlerInterface {
    func addCustomizedQA(qa: QA, toIdxQContainer idx: Int) {
        qa.qNo = QA.customizedQAId
        guard let list = QAModuleManager.moduleInUse.storage.qasList else {
            print("Warning - qas list is nil in storage")
            print("Won't add any customized qa")
            return
        }
        
        let targetVar = list[idx]
        targetVar.value.append(qa)
    }
}
