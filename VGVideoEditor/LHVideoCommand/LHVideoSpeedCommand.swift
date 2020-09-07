//
//  LHVideoSpeedCommand.swift
//  VGVideoEditor
//
//  Created by 周智伟 on 2020/9/7.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit
import AVFoundation

class LHVideoSpeedCommand: NSObject, LHVideoCommand{

    private let package: LHVideoSettingPackage
    private let mySpeed: Double
    init(settingPackage: LHVideoSettingPackage, speed:Double) {
        package = settingPackage
        mySpeed = speed
        super.init()
    }

    func invoke() {
        var insertPoint = CMTime.zero
        let multiplier = Float64(1/mySpeed)
        
        for instruction in package.instructions {
            let start = insertPoint
            
            let oldDuration = instruction.timeRange.duration
            let newDuration = CMTimeMultiplyByFloat64(oldDuration, multiplier: multiplier)
            let end = CMTimeAdd(start, newDuration)
            instruction.timeRange = CMTimeRange.init(start: start, end: end)
            insertPoint = CMTimeAdd(instruction.timeRange.start, instruction.timeRange.duration)
        }
        
        for videoTrack in package.composition.tracks(withMediaType: .video) {
            let oldDuration = videoTrack.timeRange.duration
            let newDuration = CMTimeMultiplyByFloat64(oldDuration, multiplier: multiplier)
            videoTrack.scaleTimeRange(videoTrack.timeRange, toDuration: newDuration)
        }
        
        for audioTrack in package.composition.tracks(withMediaType: .audio){
            let oldDuration = audioTrack.timeRange.duration
            let newDuration = CMTimeMultiplyByFloat64(oldDuration, multiplier: multiplier)
            audioTrack.scaleTimeRange(audioTrack.timeRange, toDuration: newDuration)
        }
        
        package.totalDuration = CMTimeMultiplyByFloat64(package.totalDuration, multiplier: multiplier)
        
        // 保证最后一条能到视频最后
        let
        if let instruction = package.instructions.last {
            instruction.timeRange = CMTimeRange.init(start: instruction.timeRange.start, end: CMTimeSubtract(package.totalDuration, instruction.timeRange.start))
        }
        
        package.videoComposition.instructions = package.instructions
    }
}
