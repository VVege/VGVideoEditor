//
//  LHVideoSettingPackage.swift
//  VGVideoEditor
//
//  Created by 周智伟 on 2020/9/6.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit
import AVFoundation

class LHVideoSettingPackage {
    
    let composition = AVMutableComposition()
    let videoComposition = AVMutableVideoComposition()
    var instructions:[AVMutableVideoCompositionInstruction] = []
    var totalDuration = CMTime.zero
    var videoTrackTransforms: [AVMutableCompositionTrack:CGAffineTransform] = [:]
    var videoLayer: CALayer?
    var parentLayer: CALayer?
    var videoFrame = CGRect.zero
    var renderSize = CGSize.zero
    
    func isEmpty() -> Bool {
        return totalDuration == CMTime.zero
    }
    
    func loadLayer() {
        if videoLayer == nil {
            videoLayer = CALayer()
        }
        if parentLayer == nil {
            parentLayer = CALayer()
            parentLayer?.addSublayer(videoLayer!)
        }
        
        videoLayer?.frame = videoFrame
        parentLayer?.frame = CGRect.init(x: 0, y: 0, width: renderSize.width, height: renderSize.height)
        
    }
    
    /*有问题 暂时不用*/
    func updateLayerInstructions() {
        instructions.first?.timeRange = CMTimeRange.init(start: .zero, end: totalDuration)
        
        var layerInstructions: [AVMutableVideoCompositionLayerInstruction] = []
        for compositionTrack in composition.tracks(withMediaType: .video) {
            let newLayerInstruction = AVMutableVideoCompositionLayerInstruction.init(assetTrack: compositionTrack)
            let transform = videoTrackTransforms[compositionTrack] ?? CGAffineTransform.identity
            
            newLayerInstruction.setTransform(transform, at: compositionTrack.timeRange.start)
            layerInstructions.append(newLayerInstruction)
        }
        instructions.first?.layerInstructions = layerInstructions
        videoComposition.instructions = instructions
    }
}
