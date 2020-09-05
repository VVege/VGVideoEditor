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
    private let composition = AVMutableComposition()
    private let videoComposition = AVMutableVideoComposition()
    private var instructions:[AVMutableVideoCompositionInstruction] = []
    private var totalDuration = CMTime.zero
}

//MARK:- Public
extension LHVideoComposition {
    
    public func duration() -> CMTime {
        return totalDuration
    }
    
    public func asset() -> AVAsset {
        return composition
    }
    
    public func videoMix() -> AVVideoComposition? {
        return videoComposition
    }
    
    public func merge(videoSource: LHVideoSource) {
        let videoUrl = URL.init(fileURLWithPath: videoSource.path)
        let videoAsset = AVURLAsset(url: videoUrl, options: nil)
        let videoDuration = videoAsset.duration
        let tuple = getTrackInfo(from: videoAsset)
        
        /// 插入视频轨道
        if let newVideoTrack = tuple.videoTrack, let newVideoMergedTrack = insertVideoTrackToComposition(videoTrack: newVideoTrack, videoDuration: videoDuration) {

            let direction = LHVideoDirection.init(transform: newVideoTrack.preferredTransform)
            var newVideoSize = newVideoTrack.naturalSize
            /// 旋转角度适配
            let adjustDirectionTransform = direction.makeAdjustTransform(natureSize: newVideoSize)
            newVideoSize = newVideoSize.applying(adjustDirectionTransform)
            if isFisrtMerge() {
                // 30fps
                videoComposition.frameDuration = CMTime.init(value: 1, timescale: 30)
                videoComposition.renderSize = newVideoSize
                composition.naturalSize = newVideoSize
                
                addNewInstruction(newVideoDuration: videoDuration, newVideoTrack: newVideoMergedTrack, preferredTransform: adjustDirectionTransform)
//                if adjustDirectionTransform != CGAffineTransform.identity {
//                    addNewInstruction(newVideoDuration: videoDuration, newVideoTrack: newVideoTrack, preferredTransform: adjustDirectionTransform)
//                }
            }else{
                let renderSize = videoComposition.renderSize
            
                let scale = min(renderSize.width/newVideoSize.width, renderSize.height/newVideoSize.height)
                
                // 移至中心点
                let translate = CGPoint.init(x: (renderSize.width - newVideoSize.width * scale) * 0.5, y: (renderSize.height - newVideoSize.height * scale) * 0.5)
                let natureTransform = newVideoTrack.preferredTransform.concatenating(adjustDirectionTransform)
                
                let preferredTransfrom = CGAffineTransform.init(a: natureTransform.a * scale, b: natureTransform.b * scale, c: natureTransform.c * scale, d: natureTransform.d * scale, tx: natureTransform.tx * scale + translate.x, ty: natureTransform.ty * scale + translate.y)
                
                addNewInstruction(newVideoDuration: videoDuration, newVideoTrack: newVideoMergedTrack, preferredTransform: preferredTransfrom)
            }
        }
        
        //插入音频轨道
        if let newAudioTrack = tuple.audioTrack, let newAudioMergedTrack = insertAudioTrackToComposition(audioTrack: newAudioTrack, videoDuration: videoDuration) {
            //TODO: 研究audioMix
            //TODO：视频所属的audio合成到一个 compositionTrack中，方便后期使用audioMix来管理
        }
        
        // 更新总时间
        totalDuration = CMTimeAdd(totalDuration, videoAsset.duration)
    }
    
    //MARK:- 单独合并音频
    ///合并音频
    public func merge(audio: LHSound) {
        
    }
    
    //MARK:- 背景相关操作
    public func setBackgroundColor(_ color: UIColor) {
        
    }
    
    public func setBackgroundImage(_ color: UIColor) {
        
    }
    
    public func setVideoFillMode() {
        
    }
    
    public func setBackgroundRatio() {
        
    }
}

//MARK:- Private
extension LHVideoComposition {
    
    private func isFisrtMerge() -> Bool {
        return totalDuration == CMTime.zero
    }
    
    private typealias VideoSourceTuple = (videoTrack: AVAssetTrack?, audioTrack: AVAssetTrack?)
    
    private func getTrackInfo(from asset: AVURLAsset) -> VideoSourceTuple {
        let videoTrack = asset.tracks(withMediaType: .video).first
        let audioTrack = asset.tracks(withMediaType: .audio).first
        return VideoSourceTuple(videoTrack,audioTrack)
    }
    
    private func getCompositionVideoTrack(assetTrack: AVAssetTrack) -> AVMutableCompositionTrack? {
        if let track = composition.mutableTrack(compatibleWith: assetTrack) {
            return track
        }
        let track = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        return track
    }
    
    private func getCompositionAudioTrack(assetTrack: AVAssetTrack) -> AVMutableCompositionTrack? {
        if let track = composition.mutableTrack(compatibleWith: assetTrack) {
            return track
        }
        let track = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        return track
    }
    
    private enum InstructionUsingType {
        case noneInstruction
        case reuseLastInstruction
        case newInstruction
    }
    
    private func determineInstructionUsingType(newVideoTrack: AVAssetTrack) -> InstructionUsingType {
        let direction = LHVideoDirection.init(transform: newVideoTrack.preferredTransform)
        let newVideoSize = newVideoTrack.naturalSize
        
        /// 首次添加视频，视频无角度
        if direction.isProperly() && totalDuration == CMTime.zero {
            return .noneInstruction
        }
        
        /// 视频无角度，且和上一个视频size相等，则可以直接合并，无需instruction
        if direction.isProperly() && newVideoSize.equalTo(composition.naturalSize) {
            return .noneInstruction
        }
        
        /// 变换与上次相同 TODO:重新判断最后的变换
        /*
        let willTransform = direction.makeAdjustTransform(natureSize: newVideoSize)
        if willTransform == lastInstructTransform {
            return .reuseLastInstruction
        }*/
        
        return .newInstruction
    }
    
    private func insertVideoTrackToComposition(videoTrack:AVAssetTrack, videoDuration: CMTime) -> AVCompositionTrack? {
        guard let compositionTrack = getCompositionVideoTrack(assetTrack: videoTrack) else {
            //TODO: 错误处理
            print("无法获取 compositionTrack")
            return nil
        }
        
        do {
            try compositionTrack.insertTimeRange(CMTimeRange.init(start: CMTime.zero, end: videoDuration), of: videoTrack, at: totalDuration)
        } catch {
            //TODO:无效视频处理
            print(error)
            return nil
        }
        return compositionTrack
    }
    
    private func insertAudioTrackToComposition(audioTrack: AVAssetTrack, videoDuration: CMTime) -> AVCompositionTrack? {
        guard let compositionTrack = getCompositionAudioTrack(assetTrack: audioTrack) else {
            //TODO: 错误处理
            print("无法获取 compositionTrack")
            return nil
        }
        
        do {
            try compositionTrack.insertTimeRange(CMTimeRange.init(start: CMTime.zero, end: videoDuration), of: audioTrack, at: totalDuration)
        } catch {
            //TODO:无效视频处理
            print(error)
            return nil
        }
        return compositionTrack
    }
    
    private func adjustLastInstructionTime(newVideoDuration: CMTime) {
        guard let instruction = instructions.last else {
            print("没有最后一个instruction")
            return
        }
        instruction.timeRange = CMTimeRange.init(start: instruction.timeRange.start, duration: CMTimeAdd(instruction.timeRange.duration, newVideoDuration))
    }
    
    ///TODO:这里要区分是开始的旋转方向，还是后来的大小变化
    private func addNewInstruction(newVideoDuration: CMTime, newVideoTrack: AVCompositionTrack, preferredTransform: CGAffineTransform) {

        let newInstruction = AVMutableVideoCompositionInstruction()
        
        newInstruction.timeRange = CMTimeRange.init(start: totalDuration, duration: newVideoDuration)
        
        let newLayerInstruction = AVMutableVideoCompositionLayerInstruction.init(assetTrack: newVideoTrack)
        
        newLayerInstruction.setTransform(preferredTransform, at: CMTime.zero)
        newInstruction.layerInstructions = [newLayerInstruction]
        instructions.append(newInstruction)
        videoComposition.instructions = instructions
    }
}
