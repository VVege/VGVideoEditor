//
//  LHVideoSource.swift
//  VGVideoEditor
//
//  Created by 周智伟 on 2020/9/2.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit

class LHVideoSource:Equatable {
    
    public var volume:Double = 1.0
    public let path:String
    
    init(videoPath: String) {
        path = videoPath
    }
    
    func copySource() -> LHVideoSource {
        let copy = LHVideoSource(videoPath: path)
        copy.volume = volume
        return copy
    }
    
    ///判断音量volume
    ///产品定义操作如此，修改视频音量需要重新加载asset
    static func == (lhs: LHVideoSource, rhs: LHVideoSource) -> Bool {
        return lhs.path == rhs.path && lhs.volume == rhs.volume
    }
}
