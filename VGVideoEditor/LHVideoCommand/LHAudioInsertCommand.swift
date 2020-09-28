//
//  LHAudioInsertCommand.swift
//  VGVideoEditor
//
//  Created by 周智伟 on 2020/9/5.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit
import AVFoundation

class LHAudioInsertCommand: NSObject, LHVideoCommand {
    
    private let package: LHVideoSettingPackage
    private let audioSource: LHAudioSource
    init(settingPackage: LHVideoSettingPackage, audio:LHAudioSource) {
        audioSource = audio
        package = settingPackage
        super.init()
    }
    
    func invoke() {
        merge(audio: audioSource)
    }
}

//MARK:- Private
extension LHAudioInsertCommand {
    private func merge(audio: LHAudioSource) {
        let audioUrl = URL.init(fileURLWithPath: audio.path)
        let audioAsset = AVURLAsset.init(url: audioUrl, options: nil)
        let audioTrack = audioAsset.tracks(withMediaType: .audio).first
        let audioDuration = audioAsset.duration
        let newMutableTrack = package.composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        if let mutableTrack = newMutableTrack, let audioTrack = audioTrack {
    
            do {
                let timeRanges = generateInsertRanges(audioDuration: audioDuration, isLoop: audio.isLoop)
                for range in timeRanges {
                    try mutableTrack.insertTimeRange(CMTimeRange.init(start: CMTime.zero, end: range.duration), of: audioTrack, at: range.start)
                }
                package.appendAudioTracks[audio.path] = mutableTrack
                let paramter = AVMutableAudioMixInputParameters.init(track: mutableTrack)
                paramter.setVolume(Float(audio.volume), at: CMTime.zero)
                paramter.audioTimePitchAlgorithm = .timeDomain
                package.audioMixParameters.append(paramter)
                package.audioMix.inputParameters = package.audioMixParameters
            } catch {
                package.error[.audio] = "\(error)音频插入失败"
            }
             
        }else{
            package.error[.audio] = "无效的音频"
        }
    }
}

//MARK:- Private
extension LHAudioInsertCommand {
    
    /// 生成插入音频的时间范围
    /// - Parameters:
    ///   - audioDuration: 音频时长
    ///   - isLoop: 是否循环
    /// - Returns:
    ///   eg. package.totalDuration = 10, audioDuration = 3
    ///       isLoop: result = [<0,3><3,6><6,9><9,10>]
    ///       !isLoop: result = [<0,3>]
    private func generateInsertRanges(audioDuration: CMTime, isLoop: Bool) -> [CMTimeRange] {
        if isLoop {
            if audioDuration >= package.totalDuration {
                let range = CMTimeRange.init(start: CMTime.zero, end: package.totalDuration)
                return [range]
            }
            
            var start = CMTime.zero
            var end = CMTime.zero
            var allRanges:[CMTimeRange] = []
            while true {
                start = end
                end = CMTimeAdd(end, audioDuration)
                var isLast = false
                if end > package.totalDuration {
                    end = package.totalDuration
                    isLast = true
                }
                let range = CMTimeRange.init(start: start, end: end)
                allRanges.append(range)
                if isLast {
                    return allRanges
                }
            }
        }else{
            var insertDuration = audioDuration
            if insertDuration > package.totalDuration {
                insertDuration = package.totalDuration
            }
            let range = CMTimeRange.init(start: CMTime.zero, end: insertDuration)
            return [range]
        }
    }
}
