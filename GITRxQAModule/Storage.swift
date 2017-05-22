//
//  Storage.swift
//  GITRxQAModule
//
//  Created by keith.lee on 2017/5/22.
//  Copyright © 2017年 git4u.com. All rights reserved.
//

import Foundation
import RxSwift


/// Storage 只作儲存不做任何邏輯運算
protocol RxQAStorageInterface {
    /// 一個儲存對應二維QA陣列的Variable List
    var qasList: [Variable<[QA]>]? { get set }
}


class RxBasicQAStorage: RxQAStorageInterface {
    var qasList: [Variable<[QA]>]?
    init(qasList: [Variable<[QA]>]? = nil){
        self.qasList = qasList
    }
}
