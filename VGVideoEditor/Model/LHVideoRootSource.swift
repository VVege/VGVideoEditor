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
        initInstruction.timeRange = CMTimeRange.init(start: CMTime.zero, duration: composition.duration)
        
        let initLayerInstruction = AVMutableVideoCompositionLayerInstruction.init(assetTrack: videoTrack)
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
            merge(videoTrack: videoTrack)
        }
    }
    
    private func merge(videoTrack: AVAssetTrack) {
        let direction = LHVideoDirection.init(transform: videoTrack.preferredTransform)
        let natureSize = videoTrack.naturalSize
        
        var needNewInstrunction = true
        if direction == .landscapeRight && instructions.count > 0 && natureSize.equalTo(composition.naturalSize) {
            //无需instruction 直接插入视频
        }else if direction == .landscapeRight && instructions.count > 0 {
            //无需新的instrnction ,修改最后一个instrction时间来实现
        }
        
        if needNewInstrunction {
            
        }
    }
}
