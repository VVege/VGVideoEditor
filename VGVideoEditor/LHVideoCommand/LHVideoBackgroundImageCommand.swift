//
//  LHVideoBackgroundImageCommand.swift
//  VGVideoEditor
//
//  Created by 周智伟 on 2020/9/6.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit
import AVFoundation

class LHVideoBackgroundImageCommand: NSObject , LHVideoCommand{
    
    private let package: LHVideoSettingPackage
    private let bgImage: UIImage?
    init(settingPackage: LHVideoSettingPackage, image: UIImage?) {
        package = settingPackage
        bgImage = image
        super.init()
    }
    
    func invoke() {
//        package.parentLayer.bgImage = bgImage?.cgImage
//        package.parentLayer.refreshLayer()
//        
//        package.loadAnimationTool()
    }
    
}
