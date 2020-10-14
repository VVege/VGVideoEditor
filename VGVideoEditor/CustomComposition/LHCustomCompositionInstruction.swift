//
//  LHCustomCompositionInstruction.swift
//  LHVideoEditorDemo
//
//  Created by 周智伟 on 2020/9/21.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit
import AVFoundation

class LHCustomCompositionInstruction: NSObject, AVVideoCompositionInstructionProtocol {
    var timeRange: CMTimeRange = .zero
    
    var enablePostProcessing: Bool = false
    
    var containsTweening: Bool = false
    
    var requiredSourceTrackIDs: [NSValue]?
    
    var passthroughTrackID: CMPersistentTrackID = 0
    
    var bgImage: CGImage?
    var renderSize: CGSize = .zero
    
    var layerInstructions: [LHCustomCompositionLayerInstruction] = []
    public var backgroundColor: CIColor = CIColor(red: 0, green: 0, blue: 0)
}
