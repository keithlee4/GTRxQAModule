//
//  QAModuleManager.swift
//  GITRxQAModule
//
//  Created by keith.lee on 2017/5/23.
//  Copyright © 2017年 git4u.com. All rights reserved.
//

import Foundation
protocol QAModuleConfig {
    associatedtype ModuleType : BasicQAModuleInterface
    associatedtype FetcherType: RxQAFetcherInterface
    static var moduleInUse: ModuleType { get }
    static func initialize(fetcher: FetcherType)
}

extension QAModuleConfig {
    static var moduleInUse: ModuleType {
        return ModuleType.sharedInstance
    }
    
    static func initialize(fetcher: FetcherType) {
        moduleInUse.useFetcher(f: fetcher)
    }
}

class QAModuleManager {
    
}
