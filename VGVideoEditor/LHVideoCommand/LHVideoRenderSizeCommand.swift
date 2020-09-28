//
//  LHVideoBackgroundAspectRatioCommand.swift
//  VGVideoEditor
//
//  Created by 周智伟 on 2020/9/5.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit
import AVFoundation

class LHVideoRenderSizeCommand: NSObject, LHVideoCommand{
    
    private let package: LHVideoSettingPackage
    private let renderSize: CGSize
    init(settingPackage: LHVideoSettingPackage, size: CGSize) {
        package = settingPackage
        renderSize = size
        super.init()
    }
    
    func invoke() {
        let videoSize = package.videoSize
        let maxSide = max(videoSize.width, videoSize.height)
        let equalSize = CGSize(width: maxSide, height: maxSide)
        package.videoComposition.renderSize = equalSize
//        package.parentLayer.size = equalSize
//        package.parentLayer.refreshLayer()
//        
//        package.loadAnimationTool()
    }
}
