//
//  LHCustomCompositionLayerInstruction.swift
//  VGVideoEditor
//
//  Created by 周智伟 on 2020/10/14.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit
import AVFoundation

class LHCustomCompositionLayerInstruction: CustomStringConvertible {
    var description: String {
        return ""
    }
    
    public var trackID: Int32 = 0
    public var timeRange: CMTimeRange = CMTimeRange.zero
//    public var transition: VideoTransition?
    public var prefferdTransform: CGAffineTransform?

}
