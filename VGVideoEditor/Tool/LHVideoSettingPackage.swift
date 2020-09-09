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
    
    /*视频*/
    let videoComposition = AVMutableVideoComposition()
    var instructions:[AVMutableVideoCompositionInstruction] = []
    var videoTrackTransforms: [AVMutableCompositionTrack:CGAffineTransform] = [:]
    
    /*音频*/
    var videoOriginalAudioTracks: [AVCompositionTrack] = []
    var appendAudioTracks: [String:AVCompositionTrack] = [:]
    var audioMixParameters: [AVMutableAudioMixInputParameters] = []
    let audioMix = AVMutableAudioMix()
    
    /*animationTool*/
    var videoLayer: CALayer?
    var parentLayer: CALayer?
    
    /*info*/
    var videoFrame = CGRect.zero
    var renderSize = CGSize.zero
    var totalDuration = CMTime.zero
    
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
}
