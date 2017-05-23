//
//  QAModule.swift
//  GITRxQAModule
//
//  Created by keith.lee on 2017/5/22.
//  Copyright © 2017年 git4u.com. All rights reserved.
//

import Foundation
import RxSwift



protocol BasicQAModuleInterface: NSObjectProtocol {
    associatedtype Storage: RxQAStorageInterface
    associatedtype Handler: RxQAHandlerInterface
    
    var fetcher: RxQAFetcherInterface? { get set }
    var storage: Storage { get set }
    var handler: Handler { get set }
    
    func useFetcher(f: RxQAFetcherInterface)
    func getNewQAsAndStore() -> Observable<()>
    func qaContainer(containerNo no: Int, pickQA pickedQA: QA)
    
    static var sharedInstance: Self { get set }
}

extension BasicQAModuleInterface {
    func useFetcher(f: RxQAFetcherInterface){
        fetcher = f
    }
    
    func getNewQAsAndStore() -> Observable<()> {
        guard let fetcher = self.fetcher else {
            print("Warning - There's no fetcher in module, won't get any qas")
            return Observable.just()
        }
        
        return
            fetcher.fetchNewQAs()
                .debug("fetch from fetcher")
                .map({[unowned self] (qas) in
                    return self.handler.parse(qasFromFetcher: qas)
                })
                .debug("fetch flat map")
                .map({[unowned self] (qasVar) -> Void in
                    self.storage.qasList = qasVar
                })
                .debug("fetch map to qas list")
        
    }

    func qaContainer(containerNo no: Int, pickQA pickedQA: QA) {
        handler.pick(idx: no, QA: pickedQA)
    }
}

/// 主要的互動class，所有外部的接口從這個class進來
final class QAModule: NSObject, BasicQAModuleInterface {

    static var sharedInstance: QAModule = QAModule.init()
    
    typealias Storage = RxBasicQAStorage
    typealias Handler = RxBasicQAHandler
    
//    static var sharedInstance: BasicQAModuleInterface = QAModule.init()
    
    var fetcher: RxQAFetcherInterface?
    var storage: RxBasicQAStorage = RxBasicQAStorage.init()
    var handler: RxBasicQAHandler = RxBasicQAHandler.init()
}


final class CustomizedQAModule: NSObject, BasicQAModuleInterface {
    static var sharedInstance: CustomizedQAModule = CustomizedQAModule.init()
    
    var fetcher: RxQAFetcherInterface?
    var storage: RxBasicQAStorage = RxBasicQAStorage.init()
    var handler: RxCustomizableQAHandler = RxCustomizableQAHandler.init()
    
    typealias Handler = RxCustomizableQAHandler
    typealias Storage = RxBasicQAStorage
}
