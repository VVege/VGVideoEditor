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
    
    private let handleError = LHVideoSettingValidation()
}

//MARK:- Public
extension LHVideoCompositionProcessor {

    public func loadCompositionInfo(composition: LHVideoComposition, loadAnimationTool: Bool = false) {
        for videoSource in composition.videos {
            merge(video: videoSource)
        }
        
        for audioSource in composition.audios {
            merge(audio: audioSource)
        }
        
        if composition.speed != 1 {
            speed(composition.speed)
        }
        
        if let cutRange = composition.cutRange {
            let ranges = generateCutRange(range: cutRange, rangeMode: composition.cutMode)
            if ranges.count > 0 {
                cut(range: ranges[0])
            }
            if ranges.count > 1 {
                cut(range: ranges[1])
            }
        }
        
        if loadAnimationTool {
            if let bgColor = composition.bgColor {
                setBackgroundColor(bgColor)
            }
        }
        
        /// 验证
        settingPackage.videoComposition.isValid(for: settingPackage.composition, timeRange: CMTimeRange.init(start: CMTime.zero, end: settingPackage.totalDuration), validationDelegate: handleError)
        return
    }
    
    //MARK:- 合并
    /// 合并视频
    public func merge(video: LHVideoSource) {
        let command = LHVideoMergeCommand.init(settingPackage: settingPackage, newVideoSource: video)
        command.invoke()
    }
    
    ///合并音频
    public func merge(audio: LHAudioSource) {
        let command = LHAudioInsertCommand.init(settingPackage: settingPackage, audio: audio)
        command.invoke()
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
    
    /// 生成需要裁剪舍弃的区域
    /// - Parameters:
    ///   - range: 操作区域
    ///   - rangeMode: 保留 or 舍弃
    /// - Returns: 需舍弃的有效区域
    private func generateCutRange(range:ClosedRange<Double>, rangeMode:LHVideoCutMode) -> [CMTimeRange] {
        let totalDuration = settingPackage.totalDuration
        let timeScale = totalDuration.timescale
        let start = CMTime.init(value: CMTimeValue(range.lowerBound * Double(timeScale)), timescale: timeScale)
        let end = CMTime.init(value: CMTimeValue(range.upperBound * Double(timeScale)), timescale: timeScale)
        guard start >= CMTime.zero, end <= totalDuration else {
            print("Error生成裁剪范围错误")
            return []
        }
        switch rangeMode {
        case .abandon:
            if start == end {
                return []
            }
            return [CMTimeRange.init(start: start, end: end)]
        case .keep:
            var array:[CMTimeRange] = []
            if end < totalDuration {
                let bigRange = CMTimeRange.init(start: end, end: totalDuration)
                array.append(bigRange)
            }
            if start > CMTime.zero {
                let smallRange = CMTimeRange.init(start: CMTime.zero, end: start)
                array.append(smallRange)
            }
            return array
        }
    }
    
}
