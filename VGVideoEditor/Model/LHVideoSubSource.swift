//
//  LHVideoSubSource.swift
//  VGVideoEditor
//
//  Created by 周智伟 on 2020/9/1.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit
import AVFoundation

class LHVideoSubSource: LHVideoSource {
    /// 指定插入时间位置
    /// 默认nil，插入尾部
    public var insertTimeRange:ClosedRange<Double>?
}

extension LHVideoSubSource {
    func cmRange() -> CMTimeRange? {
        if let range = insertTimeRange {
            let start = CMTime.init(seconds: range.upperBound * 600, preferredTimescale: 600)
            let end = CMTime.init(seconds: range.lowerBound * 600, preferredTimescale: 600)
            return CMTimeRange.init(start: start, end: end)
        }
        return nil
    }
}
