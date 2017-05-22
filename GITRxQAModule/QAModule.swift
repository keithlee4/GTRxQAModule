//
//  QAModule.swift
//  GITRxQAModule
//
//  Created by keith.lee on 2017/5/22.
//  Copyright © 2017年 git4u.com. All rights reserved.
//

import Foundation
import RxSwift


/// 主要的互動class，所有外部的接口從這個class進來
class QAModule {
    static let sharedInstance: QAModule = QAModule.init()
    
    static func useFetcher(f: RxQAFetcherInterface) {
        sharedInstance.fetcher = f
    }
    
    var fetcher: RxQAFetcherInterface?
    var storage: RxQAStorageInterface = RxBasicQAStorage.init()
    var handler: RxQAHandlerInterface = RxBasicQAHandler.init()
    var disposeBag: DisposeBag = DisposeBag.init()
    
    func getNewQAsAndStore() -> Observable<()> {
        guard let fetcher = self.fetcher else {
            print("Warning - There's no fetcher in module, won't get any qas")
            return Observable.just()
        }
        
        return
            fetcher.fetchNewQAs()
            .map({[unowned self] (qas) in
                return self.handler.parse(qasFromFetcher: qas)
            })
            .map({[unowned self] (qasVar) -> Void in
                self.storage.qasList = qasVar
            })
        
    }
    
    func qaContainer(containerNo no: Int, pickQA pickedQA: QA) {
        handler.pick(idx: no, QA: pickedQA)
    }
}
