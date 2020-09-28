//
//  LHVideoFillModeCommand.swift
//  LHVideoEditorDemo
//
//  Created by 周智伟 on 2020/9/11.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit
import AVFoundation

class LHVideoFillModeCommand: NSObject, LHVideoCommand{
    
    private let package: LHVideoSettingPackage
    private let fillMode: LHVideoFillMode
    init(settingPackage: LHVideoSettingPackage, videoFillMode: LHVideoFillMode) {
        package = settingPackage
        fillMode = videoFillMode
        super.init()
    }
    
    func invoke() {
        
//        package.parentLayer.videoFillMode = fillMode
//        package.parentLayer.refreshLayer()
//        
//        package.loadAnimationTool()
    }
}
