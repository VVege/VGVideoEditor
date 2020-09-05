//
//  LHVideoSource.swift
//  VGVideoEditor
//
//  Created by 周智伟 on 2020/9/2.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit

class LHVideoSource: NSObject {
    public let path:String
    public var duration: Double = 0
    init(videoPath: String) {
        path = videoPath
    }
}
