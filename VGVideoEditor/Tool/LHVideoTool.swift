//
//  LHVideoTool.swift
//  VGVideoEditor
//
//  Created by 周智伟 on 2020/9/3.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit
import AVFoundation

class LHVideoTool: NSObject {
    private let composition = AVMutableComposition()
    private let videoComposition = AVMutableVideoComposition()
    private var instructions:[AVMutableVideoCompositionInstruction] = []
    private var totalDuration = CMTime.zero
}

//MARK:- Public
extension LHVideoTool {
    func merge(videoSource: LHVideoSource) {
        let videoUrl = URL.init(fileURLWithPath: videoSource.path)
        let videoAsset = AVURLAsset(url: videoUrl, options: nil)
        let tuple = getTrackInfo(from: videoAsset)
        
        if let newVideoTrack = tuple.videoTrack {
            insertVideoTrackToComposition(videoTrack: newVideoTrack)
            
            let direction = LHVideoDirection.init(transform: newVideoTrack.preferredTransform)
            var newVideoSize = newVideoTrack.naturalSize
            /// 旋转角度适配
            let adjustDirectionTransform = direction.makeAdjustTransform(natureSize: newVideoSize)
            newVideoSize = newVideoSize.applying(adjustDirectionTransform)
            if isFisrtMerge() {
                // 30fps
                videoComposition.frameDuration = CMTime.init(value: 1, timescale: 30)
                videoComposition.renderSize = newVideoSize
                if adjustDirectionTransform != CGAffineTransform.identity {
                    addNewInstruction(newVideoDuration: videoAsset.duration, newVideoTrack: newVideoTrack, preferredTransform: adjustDirectionTransform)
                }
            }else{
                let scale = min(renderSize.width/natureSize.width, renderSize.height/natureSize.height)
                lastInstructionSize = CGSize.init(width: natureSize.width * scale, height: natureSize.height * scale)
                
                // 移至中心点
                let translate = CGPoint.init(x: (renderSize.width - natureSize.width * scale) * 0.5, y: (renderSize.height - natureSize.height * scale) * 0.5)
                let natureTransform = videoTrack.preferredTransform
                let preferredTransfrom = CGAffineTransform.init(a: natureTransform.a * scale, b: natureTransform.b * scale, c: natureTransform.c * scale, d: natureTransform.d * scale, tx: natureTransform.tx * scale + translate.x, ty: natureTransform.ty * scale + translate.y)
            }
        }
        
        totalDuration = CMTimeAdd(totalDuration, videoAsset.duration)
        
        //TODO:音频处理
    }
}

//MARK:- Private
extension LHVideoTool {
    
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
    
    private func insertVideoTrackToComposition(videoTrack:AVAssetTrack) {
        guard let compositionTrack = getCompositionVideoTrack(assetTrack: videoTrack) else {
            //TODO: 错误处理
            print("无法获取 compositionTrack")
            return
        }
        
        do {
            try compositionTrack.insertTimeRange(videoTrack.timeRange, of: videoTrack, at: totalDuration)
        } catch {
            //TODO:无效视频处理
            print(error)
            return
        }
    }
    
    private func adjustLastInstructionTime(newVideoDuration: CMTime) {
        guard let instruction = instructions.last else {
            print("没有最后一个instruction")
            return
        }
        instruction.timeRange = CMTimeRange.init(start: instruction.timeRange.start, duration: CMTimeAdd(instruction.timeRange.duration, newVideoDuration))
    }
    
    ///TODO:这里要区分是开始的旋转方向，还是后来的大小变化
    private func addNewInstruction(newVideoDuration: CMTime, newVideoTrack: AVAssetTrack, preferredTransform: CGAffineTransform) {

        let newInstruction = AVMutableVideoCompositionInstruction()
        newInstruction.timeRange = CMTimeRange.init(start: totalDuration, duration: newVideoDuration)
        
        let newLayerInstruction = AVMutableVideoCompositionLayerInstruction.init(assetTrack: newVideoTrack)
        
        newLayerInstruction.setTransform(preferredTransform, at: CMTime.zero)
        newInstruction.layerInstructions = [newLayerInstruction]
        instructions.append(newInstruction)
        videoComposition.instructions = instructions
    }
}
