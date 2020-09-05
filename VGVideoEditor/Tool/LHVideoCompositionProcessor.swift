//
//  LHVideoCompositionProcessor.swift
//  VGVideoEditor
//
//  Created by 周智伟 on 2020/9/5.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit
import AVFoundation

class LHVideoSettingPackage {
    let composition = AVMutableComposition()
    let videoComposition = AVMutableVideoComposition()
    var instructions:[AVMutableVideoCompositionInstruction] = []
    var totalDuration = CMTime.zero
    
    func isEmpty() -> Bool {
        return totalDuration == CMTime.zero
    }
}

class LHVideoCompositionProcessor: NSObject {
    
    public let processModel: LHVideoComposition
    
    public let settingPackage = LHVideoSettingPackage()
    
    init(model: LHVideoComposition) {
        processModel = model
        super.init()
    }
}

//MARK:- Public
extension LHVideoCompositionProcessor {
    
    //MARK:- 合并
    /// 合并视频
    public func merge(video: LHVideoSource) {
        video.duration = AVURLAsset.init(url: URL.init(fileURLWithPath: video.path)).duration.seconds
        processModel.videos.append(video)
        
        let command = LHVideoMergeCommand.init(settingPackage: settingPackage, newVideoSource: video)
        command.invoke()
    }
    
    ///合并音频
    public func merge(audio: LHSound) {
        
    }

    //MARK:- 裁剪
    public func cut(range: CMTimeRange) {
        let command = LHVideoCutCommand.init(settingPackage: settingPackage, removeTimeRange: range)
        command.invoke()
    }
    
    //MARK:- 背景相关操作
    public func setBackgroundColor(_ color: UIColor) {
        
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
