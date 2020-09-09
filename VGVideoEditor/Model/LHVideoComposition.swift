//
//  LHVideoComposition.swift
//  VGVideoEditor
//
//  Created by 周智伟 on 2020/9/4.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit
import AVFoundation

enum LHVideoCutMode {
    case abandon
    case keep
}

enum LHVideoFillMode {
    case fit
    case fill
}

class LHVideoComposition {
    public var videos:[LHVideoSource] = []
    public var audios:[LHAudioSource] = []
    public var bgSize:CGSize = CGSize.zero
    public var bgColor: UIColor?
    public var bgImage: UIImage?
    public var hasWatermark = true
    public var speed: Double = 1.0
    public var fillMode: LHVideoFillMode = .fit

    public var cutRange:ClosedRange<Double>?
    public var cutMode:LHVideoCutMode = .keep
    
    func copyComposition() -> LHVideoComposition {
        let copy = LHVideoComposition()
        var copyVideos:[LHVideoSource] = []
        var copyAudios:[LHAudioSource] = []
        for video in videos {
            let copy = video.copySource()
            copyVideos.append(copy)
        }
        
        for audio in audios {
            let copy = audio.copySource()
            copyAudios.append(copy)
        }
        
        copy.videos = copyVideos
        copy.audios = copyAudios
        copy.bgSize = bgSize
        copy.bgColor = bgColor
        copy.bgImage = bgImage
        copy.hasWatermark = hasWatermark
        copy.speed = speed
        copy.fillMode = fillMode
        copy.cutRange = cutRange
        copy.cutMode = cutMode
        return copy
    }
}
