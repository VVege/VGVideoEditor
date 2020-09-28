//
//  LHVideoSettingPackage.swift
//  VGVideoEditor
//
//  Created by 周智伟 on 2020/9/6.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit
import AVFoundation

enum LHVideoSettingStep {
    case video
    case speed
    case range
    case audio
}

class LHVideoSettingPackage {
    
    let composition = AVMutableComposition()
    var error:[LHVideoSettingStep:String] = [:]
    
    /*视频*/
    let videoComposition = AVMutableVideoComposition()
    var instructions:[AVMutableVideoCompositionInstruction] = []

    /*音频*/
    /// 视频原声音轨 key: video resourceId
    var videoOriginalAudioTracks: [String:AVCompositionTrack] = [:]
    /// 附加音轨 key: audio resourceId
    var appendAudioTracks: [String:AVCompositionTrack] = [:]
    var audioMixParameters: [AVMutableAudioMixInputParameters] = []
    let audioMix = AVMutableAudioMix()
    
    /*animationTool*/
    let videoLayer = CALayer()
    let parentLayer = CALayer()
    var watermarkLayer = CALayer()
    
    /*info*/
    var videoSize = CGSize.zero
    var totalDuration = CMTime.zero
    
    func isEmpty() -> Bool {
        return totalDuration == CMTime.zero
    }
    
    func loadAnimationTool() {
        if videoComposition.animationTool == nil {
            parentLayer.isGeometryFlipped = true
            
            parentLayer.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
            videoLayer.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
            parentLayer.addSublayer(videoLayer)
            
            watermarkLayer = LHVideoWatermarkGenerator.generateWatermark(videoSize: videoSize)
            parentLayer.addSublayer(watermarkLayer)
            videoComposition.animationTool = AVVideoCompositionCoreAnimationTool.init(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        }
    }
}
