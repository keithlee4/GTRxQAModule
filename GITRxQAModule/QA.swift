//
//  QA.swift
//  GITRxQAModule
//
//  Created by keith.lee on 2017/5/22.
//  Copyright © 2017年 git4u.com. All rights reserved.
//

import Foundation

class QA: Hashable {
    
    /// 自定義的QA id
    static var customizedQAId : Int {
        return -1
    }
    
    var qNo: Int
    var qTitle: String
    var ansContent: String?
    
    var hashValue: Int {
        return qNo
    }
    
    var isCustomized: Bool {
        return qNo == QA.customizedQAId
    }
    
    static func ==(lhs: QA, rhs: QA) -> Bool {
        return lhs.qNo == rhs.qNo && lhs.qTitle == rhs.qTitle
    }
    
    init(qNo: Int, qTitle: String, ansContent: String? = nil) {
        self.qNo = qNo
        self.qTitle = qTitle
        self.ansContent = ansContent
    }
}


//FIXME: For test only 

extension QA {
    static func fake(count: Int) -> [QA] {
        var fakes = [QA]()
        for i in 0..<count {
            let qa = QA.init(qNo: i, qTitle: "fakeTitle\(i)")
            fakes.append(qa)
        }
        
        return fakes
    }
}
