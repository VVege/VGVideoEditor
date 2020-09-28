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
    public let settingPackage: LHVideoSettingPackage
    
    private let handleError = LHVideoSettingValidation()
    
    init(composition: LHVideoComposition, loadAnimationTool: Bool = false) {
        settingPackage = LHVideoSettingPackage.init()
        super.init()
        loadCompositionInfo(composition: composition, loadAnimationTool: loadAnimationTool)
    }
}

//MARK:- Public
extension LHVideoCompositionProcessor {
    public func error() -> String? {
        for key in settingPackage.error.keys {
            if let string = settingPackage.error[key] {
                return string
            }
        }
        return nil
    }
}

//MARK:- Private
extension LHVideoCompositionProcessor {

     private func loadCompositionInfo(composition: LHVideoComposition, loadAnimationTool: Bool = false) {
        settingPackage.error.removeAll()
        
        /// 先处理视频
        /// 后处理音频，保证音轨不会被变速，裁剪影响
        for videoSource in composition.videos {
            merge(video: videoSource, composition: composition)
        }
        
        /// 先处理变速
        /// 后处理裁剪
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
        
        for audioSource in composition.audios {
            merge(audio: audioSource)
        }
        
        if loadAnimationTool {
            if composition.hasWatermark {
                settingPackage.loadAnimationTool()
            }
        }
        
        ///TODO:测试背景
        /*
        if let bgImage = composition.bgImage {
            settingPackage.videoComposition.customVideoCompositorClass = LHCustomVideoCompositor.self
            
        }*/
        
        /// 验证
        settingPackage.videoComposition.isValid(for: settingPackage.composition, timeRange: CMTimeRange.init(start: CMTime.zero, end: settingPackage.totalDuration), validationDelegate: handleError)
        return
    }
    
    //MARK:- 修改参数
    /// 修改音频音量
    public func updateVolume(audio: LHAudioSource) {
        if let audioTrack = settingPackage.appendAudioTracks[audio.path] {
            let command = LHAudioVolumeCommand.init(settingPackage: settingPackage, audioTrack: audioTrack, audioVolume: audio.volume)
            command.invoke()
        }else{
            print("未找到指定音频")
        }
    }
    
    ///修改视频音量
    public func updateVolume(video: LHVideoSource) {
        if let audioTrack = settingPackage.videoOriginalAudioTracks[video.path] {
            let command = LHAudioVolumeCommand.init(settingPackage: settingPackage, audioTrack: audioTrack, audioVolume: video.volume * 0.7)
            command.invoke()
        }else{
            print("未找到指定音频")
        }
    }
    
    //MARK:- 合并
    /// 合并视频
    private func merge(video: LHVideoSource, composition: LHVideoComposition) {
        
        let command = LHVideoMergeCommand.init(settingPackage: settingPackage, newVideoSource: video, videoBgColor: composition.bgColor?.cgColor, videoFillMode: composition.fillMode, videoRenderRatio: composition.renderRatio)
        command.invoke()
    }
    
    ///合并音频
    private func merge(audio: LHAudioSource) {
        let command = LHAudioInsertCommand.init(settingPackage: settingPackage, audio: audio)
        command.invoke()
    }
    
    //MARK:- 倍速
    private func speed(_ speed: Double){
        let command = LHVideoSpeedCommand.init(settingPackage: settingPackage, speed: speed)
        command.invoke()
    }

    //MARK:- 裁剪
    private func cut(range: CMTimeRange) {
        let command = LHVideoCutCommand.init(settingPackage: settingPackage, removeTimeRange: range)
        command.invoke()
    }
    
    //MARK:- 背景相关操作
    private func setBackgroundColor(_ color: UIColor) {
        let command = LHVideoBackgroundColorCommand.init(settingPackage: settingPackage, color: color)
        command.invoke()
    }
    
    private func setBackgroundImage(_ image: UIImage?) {
        let command = LHVideoBackgroundImageCommand.init(settingPackage: settingPackage, image: image)
        command.invoke()
    }
    
    private func setVideoFillMode(_ fillMode: LHVideoFillMode) {
        let command = LHVideoFillModeCommand.init(settingPackage: settingPackage, videoFillMode: fillMode)
        command.invoke()
    }
    
    private func setRenderSize(_ renderSize: CGSize) {
        let command = LHVideoRenderSizeCommand.init(settingPackage: settingPackage, size: renderSize)
        command.invoke()
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
