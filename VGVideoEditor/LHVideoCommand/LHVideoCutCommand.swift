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
        
        for compositionTrack in package.composition.tracks(withMediaType: .audio) {
            compositionTrack.removeTimeRange(cutRange)
//            subRange(compositionTrack: compositionTrack, range: cutRange)
        }
        
        for compositionTrack in package.composition.tracks(withMediaType: .video) {
            compositionTrack.removeTimeRange(cutRange)
//            subRange(compositionTrack: compositionTrack, range: cutRange)
            
        }        
        
//        package.updateLayerInstructions()
        
//        package.instructions[0].timeRange = CMTimeRange.init(start: CMTime.init(value: 0, timescale: 600), end: CMTime.init(value: 2 * 600, timescale: 600))
//        package.instructions[1].timeRange = CMTimeRange.init(start: CMTime.init(value: 2, timescale: 600), end: CMTime.init(value: 8 * 600, timescale: 600))
//        var
//        for (index, instruction) in package.instructions.enumerated() {
//            if index == 0 {
//                if let subtractRange = instruction.timeRange.subtract(other: cutRange) {
//                    instruction.timeRange = subtractRange
//                }
//            }else{
//
//            }
//
//        }
        
        package.videoComposition.instructions = package.instructions
        package.totalDuration = CMTimeSubtract(package.totalDuration, cutRange.duration)        
    }
    
    func subRange(compositionTrack: AVMutableCompositionTrack, range:CMTimeRange) {
        
        let endPoint = range.end
        if CMTimeCompare(package.totalDuration, endPoint) != -1 {
            compositionTrack.removeTimeRange(CMTimeRange.init(start: endPoint, end: CMTimeSubtract(package.totalDuration, endPoint)))
        }
        
        if CMTimeGetSeconds(range.start) > 0 {
            compositionTrack.removeTimeRange(CMTimeRange.init(start: CMTime.zero, end: range.start))
        }
    }
}

extension CMTimeRange {
    func subtract(other: CMTimeRange) -> CMTimeRange? {
        let intersection = self.intersection(other)
        guard intersection.isValid else {
            return nil
        }
        
        /// 0 或 负数 都返回 0
        if other.containsTimeRange(self) {
            return CMTimeRange.zero
        }
        
        ///如果包涵则，start不变，duration减少
        if self.containsTimeRange(other) {
            return CMTimeRange.init(start: start, end: end - other.duration)
        }
        
        if other.start < start && other.end > start {
            return CMTimeRange.init(start: other.end, end: end)
        }
        
        if other.start < end && other.end > end {
            return CMTimeRange.init(start: start, end: other.start)
        }
        
        return nil
    }
}
