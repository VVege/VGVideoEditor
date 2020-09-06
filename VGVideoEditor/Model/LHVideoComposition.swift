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
    public var videoSize: CGSize = CGSize.zero
    public var bgSize:CGSize = CGSize.zero
    public var duration: Double = 0
    public var bgColor: UIColor?
    public var bgImage: UIImage?
    public var hasWatermark = true
    public var rate: Double = 1.0
}

