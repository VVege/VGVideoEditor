//
//  LHVideoSource.swift
//  VGVideoEditor
//
//  Created by 周智伟 on 2020/9/2.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit

class LHVideoSource:Equatable {
    
    public let path:String
    init(videoPath: String) {
        path = videoPath
    }
    
    func copySource() -> LHVideoSource {
        let copy = LHVideoSource.init(videoPath: path)
        return copy
    }
    
    static func == (lhs: LHVideoSource, rhs: LHVideoSource) -> Bool {
        return lhs.path == rhs.path
    }
    
}
