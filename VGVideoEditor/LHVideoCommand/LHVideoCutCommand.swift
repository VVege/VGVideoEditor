//
//  LHVideoCutCommand.swift
//  VGVideoEditor
//
//  Created by 周智伟 on 2020/9/5.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit
import AVFoundation

class LHVideoCutCommand: NSObject, LHVideoCommand {

    private let package: LHVideoSettingPackage
    private let cutRange:CMTimeRange
    
    init(settingPackage: LHVideoSettingPackage, removeTimeRange:CMTimeRange) {
        cutRange = removeTimeRange
        package = settingPackage
        super.init()
    }

    func invoke() {
        cut()
    }
}

//MARK:- Private
extension LHVideoCutCommand {
    private func cut() {
        let compositionRange = CMTimeRange.init(start: CMTime.zero, end: package.totalDuration)
        guard compositionRange.containsTimeRange(cutRange) else {
            //TODO: 错误处理
            print("裁剪时间错误")
            return
        }
        
        ///裁剪track
        for compositionTrack in package.composition.tracks(withMediaType: .audio) {
            compositionTrack.removeTimeRange(cutRange)
        }
        
        for compositionTrack in package.composition.tracks(withMediaType: .video) {
            compositionTrack.removeTimeRange(cutRange)
        }
        
        ///更新时间
        package.totalDuration = CMTimeSubtract(package.totalDuration, cutRange.duration)
        
        ///更新instructions时间
        /// tips：每个track的timeRange都是从0开始
        /// 持续时间长度不一样，最后添加的track长度是从 0到视频总时长
        let videoTracks = package.composition.tracks(withMediaType: .video)
        
        var insertPoint = CMTime.zero
        var lastTrackDuration = CMTime.zero
        for (index, instruction) in package.instructions.enumerated() {
            let track = videoTracks[index]
            let currentTrackDuration = track.timeRange.duration
            var currentVideoDuration = CMTime.zero
            /// track可能全部被删减掉了。导致duration失效
            if currentTrackDuration.isValid {
                currentVideoDuration = CMTimeSubtract(currentTrackDuration, lastTrackDuration)
                lastTrackDuration = currentTrackDuration
            }

            let end = CMTimeAdd(insertPoint, currentVideoDuration)
            instruction.timeRange = CMTimeRange.init(start: insertPoint, end: end)
            
            insertPoint = instruction.timeRange.end
        }

        package.videoComposition.instructions = package.instructions
        
    }
}
