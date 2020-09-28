//
//  LHAudioVolumeCommand.swift
//  VGVideoEditor
//
//  Created by 伟哥 on 2020/9/10.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit
import AVFoundation

class LHAudioVolumeCommand: NSObject, LHVideoCommand {
    private let package: LHVideoSettingPackage
    private let track: AVCompositionTrack
    private let volume: Double
    init(settingPackage: LHVideoSettingPackage, audioTrack:AVCompositionTrack, audioVolume: Double) {
        track = audioTrack
        package = settingPackage
        volume = audioVolume
        super.init()
    }
    
    func invoke() {
        package.audioMixParameters.removeAll { (parameter) -> Bool in
            return parameter.trackID == track.trackID
        }
        
        let parameter = AVMutableAudioMixInputParameters.init(track: track)
        parameter.setVolume(Float(volume), at: CMTime.zero)
        parameter.audioTimePitchAlgorithm = .timeDomain
        package.audioMixParameters.append(parameter)

        package.audioMix.inputParameters = package.audioMixParameters
    }
}
