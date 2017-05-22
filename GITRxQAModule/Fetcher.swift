//
//  Fetcher.swift
//  GITRxQAModule
//
//  Created by keith.lee on 2017/5/22.
//  Copyright © 2017年 git4u.com. All rights reserved.
//

import Foundation
import RxSwift

/// Interface to fetch different type of qas of each projects, you must create specific class conforming to this protocol
/// and set it as whole module singleton instance.

/// 必須宣告每一個案子專屬的產出邏輯以及所有在api層溝通時必要的參數。
protocol RxQAFetcherInterface {
    
    /// 用於取得通用QA清單的方法，此方法只回傳一維清單，存入storage，二維轉換交由Handler處理
    ///
    /// - Returns:
    func fetchNewQAs() -> Observable<[QA]>

    
    /// 獲取使用者已設定的問題清單列表
    ///
    /// - Returns:
    func fetchUserQAs() -> Observable<[QA]>
}



//TODO: For test only
class RxQATestFetcher: RxQAFetcherInterface {
    func fetchNewQAs() -> Observable<[QA]> {
        return Observable.just(QA.fake(count: 15))
    }
    
    func fetchUserQAs() -> Observable<[QA]> {
        return Observable.just(QA.fake(count: 15))
    }
}
