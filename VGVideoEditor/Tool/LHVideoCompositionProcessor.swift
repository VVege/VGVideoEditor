//
//  LHVideoCompositionProcessor.swift
//  VGVideoEditor
//
//  Created by 周智伟 on 2020/9/5.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit
import AVFoundation

class LHVideoCompositionProcessor: NSObject {
    public let settingPackage = LHVideoSettingPackage()
}

//MARK:- Public
extension LHVideoCompositionProcessor {

    public typealias LHVideoCompositionLoadTuple = (asset: AVAsset, videoComposition: AVVideoComposition?, videoFrame:CGRect, renderSize:CGSize)
    
    public func loadCompositionInfo(composition: LHVideoComposition) ->  LHVideoCompositionLoadTuple {
        for videoSource in composition.videos {
            merge(video: videoSource)
        }
    
        return (asset: settingPackage.composition, videoComposition: settingPackage.videoComposition, videoFrame: settingPackage.videoFrame, renderSize: settingPackage.renderSize)
    }
    
    //MARK:- 合并
    /// 合并视频
    public func merge(video: LHVideoSource) {
        video.duration = AVURLAsset.init(url: URL.init(fileURLWithPath: video.path)).duration.seconds
        
        let command = LHVideoMergeCommand.init(settingPackage: settingPackage, newVideoSource: video)
        command.invoke()
    }
    
    ///合并音频
    public func merge(audio: LHSoundSource) {
        
    }
    
    //MARK:- 倍速
    public func speed(_ speed: Double){
        let command = LHVideoSpeedCommand.init(settingPackage: settingPackage, speed: speed)
        command.invoke()
    }

    //MARK:- 裁剪
    public func cut(range: CMTimeRange) {
        let command = LHVideoCutCommand.init(settingPackage: settingPackage, removeTimeRange: range)
        command.invoke()
    }
    
    //MARK:- 背景相关操作
    public func setBackgroundColor(_ color: UIColor) {
        let command = LHVideoBackgroundColorCommand.init(settingPackage: settingPackage, color: color)
        command.invoke()
    }
    
    public func setBackgroundImage(_ color: UIColor) {
        
    }
    
    public func setVideoFillMode() {
        
    }
    
    public func setBackgroundRatio() {
        
    }
}

//MARK:- Private
extension LHVideoCompositionProcessor {
    
}
