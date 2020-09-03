//
//  LHVideoSource.swift
//  VGVideoEditor
//
//  Created by 周智伟 on 2020/9/1.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit
import AVFoundation

class LHVideoRootSource: LHVideoSource {
    public var volume:CGFloat = 1.0
    
    private var subSources:[LHVideoSubSource] = []
    private var totalDuration = CMTime.zero
    private let composition = AVMutableComposition()
    private let videoComposition = AVMutableVideoComposition()
    private var instructions:[AVMutableVideoCompositionInstruction] = []
    private var lastInstructionSize: CGSize = .zero
    override init(videoPath: String) {
        super.init(videoPath: videoPath)
        initComposition()
    }
    
    private func initComposition() {
        let videoUrl = URL.init(fileURLWithPath: path)
        let videoAsset = AVURLAsset(url: videoUrl, options: nil)
        
        guard let videoTrack = videoAsset.tracks(withMediaType: .video).first else {
            //TODO:无效视频处理
            return
        }
        
        totalDuration = videoAsset.duration
        // 30 fps
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        videoComposition.renderSize = videoTrack.naturalSize
        let videoCompositionTrack = compositionVideoTrack(assetTrack: videoTrack)
        do {
            try videoCompositionTrack?.insertTimeRange(videoTrack.timeRange, of: videoTrack, at: CMTime.zero)
        } catch {
            //TODO:无效视频处理
            print(error)
            return
        }
        
        let direction = LHVideoDirection.init(transform: videoTrack.preferredTransform)
        let natureSize = videoTrack.naturalSize
        
        let initInstruction = AVMutableVideoCompositionInstruction()
        initInstruction.timeRange = CMTimeRange.init(start: CMTime.zero, duration: totalDuration)
        
        let initLayerInstruction = AVMutableVideoCompositionLayerInstruction.init(assetTrack: videoTrack)
        //TODO：查看这里transform原理，竖屏的方向也要调整为 portrait 吗？
        let adjustTransform = direction.makeAdjustTransform(natureSize: natureSize)
        initLayerInstruction.setTransform(adjustTransform, at: CMTime.zero)
        
        initInstruction.layerInstructions = [initLayerInstruction]
        instructions.append(initInstruction)
        videoComposition.instructions = instructions
        
        ///TODO:查看正常情况的renderSize
        if direction == .portrait || direction == .portraitUpsideDown {
            videoComposition.renderSize = CGSize(width: natureSize.height, height: natureSize.width)
        }
        
        composition.naturalSize = videoComposition.renderSize
        lastInstructionSize = videoComposition.renderSize
    }
}

//MARK:- Public
extension LHVideoRootSource {
    public func append(subSource: LHVideoSubSource) {
        subSources.append(subSource)
        mergeComposition(subSource: subSource)
    }
    
    public func asset() -> AVAsset {
        return composition
    }
    
    public func videoSettings() -> AVVideoComposition {
        return videoComposition
    }
}

//MARK:- Private TODO:合并音频
extension LHVideoRootSource {
    
    private func compositionVideoTrack(assetTrack: AVAssetTrack) -> AVMutableCompositionTrack? {
        if let track = composition.mutableTrack(compatibleWith: assetTrack) {
            return track
        }
        let track = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        return track
    }
    
    private func mergeComposition(subSource: LHVideoSubSource){
        let videoUrl = URL.init(fileURLWithPath: subSource.path)
        let videoAsset = AVURLAsset(url: videoUrl, options: nil)
        if let videoTrack = videoAsset.tracks(withMediaType: .video).first {
            merge(videoTrack: videoTrack, duration: videoAsset.duration)
        }else{
            print("mergeComposition--error")
            //TODO:错误处理
        }
    }
    
    private func merge(videoTrack: AVAssetTrack, duration: CMTime) {
        let direction = LHVideoDirection.init(transform: videoTrack.preferredTransform)
        var natureSize = videoTrack.naturalSize
        let compositionTrack = compositionVideoTrack(assetTrack: videoTrack)
        
        var needNewInstrunction = true
        if direction == .landscapeRight && natureSize.equalTo(composition.naturalSize) {
            //无需instruction 直接插入视频
            do {
                try compositionTrack?.insertTimeRange(CMTimeRange.init(start: CMTime.zero, duration: duration), of: videoTrack, at: totalDuration)
                needNewInstrunction = false
            } catch {
                //TODO:错误处理
            }
        }else if direction == .landscapeRight, let instruction = instructions.last, let layerInstruction = instruction.layerInstructions.first {
            //TODO:这里还要考虑多个 LayerInstruction 到底使用哪一个的问题
            //无需新的instrnction ,修改最后一个instrction时间来实现
            var startTransform = CGAffineTransform.identity
            layerInstruction.getTransformRamp(for: totalDuration, start: &startTransform, end: nil, timeRange: nil)
        
            if startTransform == videoTrack.preferredTransform && lastInstructionSize.equalTo(natureSize) {
                instruction.timeRange = CMTimeRange.init(start: instruction.timeRange.start, duration: CMTimeAdd(instruction.timeRange.duration, duration))
                do {
                    try compositionTrack?.insertTimeRange(CMTimeRange.init(start: CMTime.zero, duration: duration), of: videoTrack, at: totalDuration)
                } catch {
                    //TODO:错误处理
                }
                needNewInstrunction = false
            }else{
                needNewInstrunction = true
            }
        }
        
        if needNewInstrunction {
            do {
                try compositionTrack?.insertTimeRange(CMTimeRange.init(start: CMTime.zero, duration: duration), of: videoTrack, at: totalDuration)
            } catch {
                //TODO:错误处理
            }
            
            let newInstruction = AVMutableVideoCompositionInstruction()
            newInstruction.timeRange = CMTimeRange.init(start: totalDuration, duration: duration)
            
            let newLayerInstruction = AVMutableVideoCompositionLayerInstruction.init(assetTrack: videoTrack)
            let renderSize = videoComposition.renderSize
            if direction == .portrait || direction == .portraitUpsideDown {
                natureSize = CGSize.init(width: natureSize.height, height: natureSize.width)
            }
            
            let scale = min(renderSize.width/natureSize.width, renderSize.height/natureSize.height)
            lastInstructionSize = CGSize.init(width: natureSize.width * scale, height: natureSize.height * scale)
            
            // 移至中心点
            let translate = CGPoint.init(x: (renderSize.width - natureSize.width * scale) * 0.5, y: (renderSize.height - natureSize.height * scale) * 0.5)
            let natureTransform = videoTrack.preferredTransform
            let preferredTransfrom = CGAffineTransform.init(a: natureTransform.a * scale, b: natureTransform.b * scale, c: natureTransform.c * scale, d: natureTransform.d * scale, tx: natureTransform.tx * scale + translate.x, ty: natureTransform.ty * scale + translate.y)
            newLayerInstruction.setTransform(preferredTransfrom, at: CMTime.zero)
            
            newInstruction.layerInstructions = [newLayerInstruction]
            instructions.append(newInstruction)
            videoComposition.instructions = instructions
        }
    }
}
