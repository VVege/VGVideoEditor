//
//  LHVideoExporter.swift
//  VGVideoEditor
//
//  Created by 周智伟 on 2020/9/5.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit
import AVFoundation

class LHVideoExporter: NSObject {
    public let layer = CALayer()
    private var assetGenerator: AVAssetImageGenerator?
    private var videoDuration = CMTime.zero
    private let queue = DispatchQueue.init(label: "dwdwdw", qos: DispatchQoS.userInteractive)
    init(processer: LHVideoCompositionProcessor) {
        super.init()
        let assetGenerator = AVAssetImageGenerator(asset: processer.settingPackage.composition)
        assetGenerator.requestedTimeToleranceAfter = CMTime.zero
        assetGenerator.requestedTimeToleranceBefore = CMTime.zero
        assetGenerator.appliesPreferredTrackTransform = true
        assetGenerator.videoComposition = processer.settingPackage.videoComposition
        self.assetGenerator = assetGenerator
        
        videoDuration = processer.settingPackage.totalDuration
        layer.frame = CGRect(x: 0, y: 0, width: 300, height: 400)
        layer.contentsGravity = .center
    }
    
    func export() {
        
        let timeScale = 30.0
        let duration = videoDuration.seconds
        let total = timeScale * duration
        NSLog("测试导出")
//        queue.async { [weak self] in
            for i in  0...Int(total) {
                var actualTime:CMTime = CMTime.zero
                let currentTime = CMTime.init(value: CMTimeValue(i), timescale: 30)
                if let cgImage = try? self.assetGenerator?.copyCGImage(at: currentTime, actualTime: &actualTime) {
                    CATransaction.begin()
                    CATransaction.setDisableActions(true)
                    self.layer.contents = cgImage
                    CATransaction.commit()
                }
                NSLog("导出进度：%f", Double(i)/total)
//            }
            NSLog("导出完成")
        }
    }
    
}
