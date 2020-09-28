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

enum LHVideoQuality {
    case original
    case p480
    case p720
    case p1080
    
    
    func exportPreset() -> String {
        switch self {
        case .original:
            return AVAssetExportPresetHighestQuality
        case .p1080:
            return AVAssetExportPreset1920x1080
        case .p720:
            return AVAssetExportPreset1280x720
        case .p480:
            return AVAssetExportPreset640x480
        }
    }
    
    func name() -> String {
        switch self {
        case .original:
            return "原画质"
        case .p480:
            return "480p"
        case .p720:
            return "720p"
        case .p1080:
            return "1080p"
        }
    }
}

enum LHVideoRenderRatio {
    case original
    case r6_7
    case r9_16
    case r16_9
    case r3_4
    case r4_3
    case r1_2
    case r2_1
    case r1_1
}

class LHVideoComposition {
    public var videos:[LHVideoSource] = []
    public var audios:[LHAudioSource] = []
    public var bgColor: UIColor?
    public var bgImage: UIImage?
    public var hasWatermark = true
    public var speed: Double = 1.0
    public var fillMode: LHVideoFillMode = .fit
    public var quality: LHVideoQuality = .original
    public var renderRatio: LHVideoRenderRatio = .original

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
        copy.bgColor = bgColor
        copy.bgImage = bgImage
        copy.hasWatermark = hasWatermark
        copy.speed = speed
        copy.fillMode = fillMode
        copy.cutRange = cutRange
        copy.cutMode = cutMode
        copy.quality = quality
        copy.renderRatio = renderRatio
        return copy
    }
}
