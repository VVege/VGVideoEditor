//
//  LHVideoComposition.swift
//  VGVideoEditor
//
//  Created by 周智伟 on 2020/9/4.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit
import AVFoundation

class LHVideoComposition: NSObject {
    public var videos:[LHVideoSource] = []
    public var sounds:[LHSoundSource] = []
    public var videoFrame: CGRect = CGRect.zero
    public var bgSize:CGSize = CGSize.zero
    public var duration: Double = 0
    public var bgColor: UIColor?
    public var bgImage: UIImage?
    public var hasWatermark = true
    public var rate: Double = 1.0
    public var fillMode: Int = 0

    public var cutRange:ClosedRange<Double>?
    public var cutMode:Int = 0
    
    func copyComposition() -> LHVideoComposition {
        let copy = LHVideoComposition()
        var copyVideos:[LHVideoSource] = []
        var copySounds:[LHSoundSource] = []
        for video in videos {
            let copy = video.copySource()
            copyVideos.append(copy)
        }
        
        for sound in sounds {
            let copy = sound.copySource()
            copySounds.append(copy)
        }
        
        copy.videos = copyVideos
        copy.sounds = copySounds
        copy.videoFrame = videoFrame
        copy.bgSize = bgSize
        copy.duration = duration
        copy.bgColor = bgColor
        copy.bgImage = bgImage
        copy.hasWatermark = hasWatermark
        copy.rate = rate
        copy.fillMode = fillMode
        copy.cutRange = cutRange
        copy.cutMode = cutMode
        return copy
    }
}

