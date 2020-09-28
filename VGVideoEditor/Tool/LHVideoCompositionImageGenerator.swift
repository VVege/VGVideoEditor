//
//  LHVideoExporter.swift
//  VGVideoEditor
//
//  Created by 周智伟 on 2020/9/5.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit
import AVFoundation

class LHVideoCompositionImageGenerator: NSObject {
    
    public let uuid = UUID().uuidString
    
    private var assetGenerator: AVAssetImageGenerator?
    private let queue = DispatchQueue.init(label: "LHVideoCompositionImageGenerator", qos: DispatchQoS.userInteractive)
    private var composition: LHVideoComposition!
    private var imageCache:[CMTimeValue:CGImage] = [:]
}

//MARK:- Public
extension LHVideoCompositionImageGenerator {
    
    /// 刷新composition
    /// - Parameters:
    ///   - newComposition: newComposition
    ///   - imageSize: size
    ///   - isFillBackground: 是否默认填充：帧列表不需要带有背景色的图片
    public func refresh(newComposition: LHVideoComposition, imageSize: CGSize = CGSize(width: 200, height: 200), isFillBackground:Bool = true) {
        self.composition = newComposition.copyComposition()
        if isFillBackground {
            self.composition.renderRatio = .r1_1
            self.composition.fillMode = .fill
        }
        self.imageCache.removeAll()
        let processor = LHVideoCompositionProcessor(composition: self.composition)
        if let errorMessage = processor.error() {
            print("LHVideoCompositionImageGenerator Error:\(errorMessage)")
        }else{
            let assetGenerator = AVAssetImageGenerator(asset: processor.settingPackage.composition)
            assetGenerator.requestedTimeToleranceAfter = CMTime.zero
            assetGenerator.requestedTimeToleranceBefore = CMTime.zero
            assetGenerator.appliesPreferredTrackTransform = true
            assetGenerator.videoComposition = processor.settingPackage.videoComposition
            assetGenerator.maximumSize = imageSize
            self.assetGenerator = assetGenerator
        }
    }
    
    public func timeValue(seconds: Double) -> CMTimeValue {
        return CMTimeValue(seconds * 600)
    }
    
    typealias LHVideoCompositionImageGeneratorFinish = (CGImage?,CMTimeValue,String) -> Void
    public func loadImage(timeValue: CMTimeValue, finish:@escaping LHVideoCompositionImageGeneratorFinish) {
        let currentTime = CMTime.init(value: timeValue, timescale: 600)
        if let image = imageCache[timeValue] {
            finish(image, timeValue, uuid)
            return
        }
        
        queue.async { [weak self] in
            guard let weakSelf = self else {
                return
            }
            
            var actualTime:CMTime = CMTime.zero
            if let cgImage = try? weakSelf.assetGenerator?.copyCGImage(at: currentTime, actualTime: &actualTime) {
                weakSelf.imageCache[timeValue] = cgImage
            }
            
            DispatchQueue.main.async {[weak self] in
                finish(self?.imageCache[timeValue], timeValue, self?.uuid ?? "")
            }
        }
    }
}
