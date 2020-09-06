//
//  LHVideoBackgroundContentCommand.swift
//  VGVideoEditor
//
//  Created by 周智伟 on 2020/9/5.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit
import AVFoundation

class LHVideoBackgroundColorCommand: NSObject , LHVideoCommand{
    
    private let package: LHVideoSettingPackage
    private let bgColor: UIColor
    init(settingPackage: LHVideoSettingPackage, color: UIColor) {
        //TODO:考虑是否copy问题
        package = settingPackage
        bgColor = color
        super.init()
    }
    
    func invoke() {
        package.loadLayer()
        package.parentLayer?.backgroundColor = bgColor.cgColor
        package.videoComposition.animationTool = AVVideoCompositionCoreAnimationTool.init(postProcessingAsVideoLayer: package.videoLayer!, in: package.parentLayer!)
    }
    
}
