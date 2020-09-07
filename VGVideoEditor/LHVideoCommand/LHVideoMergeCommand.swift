//
//  LHVideoMergeCommand.swift
//  VGVideoEditor
//
//  Created by 周智伟 on 2020/9/5.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit
import AVFoundation

class LHVideoMergeCommand: NSObject, LHVideoCommand {
    
    private let package:LHVideoSettingPackage
    private let videoSource: LHVideoSource
    init(settingPackage: LHVideoSettingPackage, newVideoSource: LHVideoSource) {
        //TODO:考虑是否copy问题
        package = settingPackage
        videoSource = newVideoSource
        super.init()
    }
    
    func invoke() {
        merge(videoSource: videoSource)
    }
}

//MARK:- Private Merge
extension LHVideoMergeCommand {
    private func merge(videoSource: LHVideoSource) {
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
                        
            if package.isEmpty() {
                // 30fps
                package.videoComposition.frameDuration = CMTime.init(value: 1, timescale: 30)
                package.videoComposition.renderSize = newVideoSize
                package.composition.naturalSize = newVideoSize
                /// 更新package
                package.videoFrame = CGRect(x: 0, y: 0, width: newVideoSize.width, height: newVideoSize.height)
                package.renderSize = package.videoFrame.size
                
                addNewInstruction(newVideoDuration: videoDuration, newVideoTrack: newVideoMergedTrack, preferredTransform: adjustDirectionTransform)
//                                if adjustDirectionTransform != CGAffineTransform.identity {
//                                    addNewInstruction(newVideoDuration: videoDuration, newVideoTrack: newVideoTrack, preferredTransform: adjustDirectionTransform)
//                                }
            }else{
                let renderSize = package.videoComposition.renderSize
                
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
        package.totalDuration = CMTimeAdd(package.totalDuration, videoAsset.duration)
    }
}

//MARK:- Private Get
extension LHVideoMergeCommand {
    private typealias VideoSourceTuple = (videoTrack: AVAssetTrack?, audioTrack: AVAssetTrack?)
    
    private func getTrackInfo(from asset: AVURLAsset) -> VideoSourceTuple {
        let videoTrack = asset.tracks(withMediaType: .video).first
        let audioTrack = asset.tracks(withMediaType: .audio).first
        return VideoSourceTuple(videoTrack,audioTrack)
    }
    
    private func getCompositionVideoTrack(assetTrack: AVAssetTrack) -> AVMutableCompositionTrack? {
        //暂时都使用新轨道
        /*
        if let track = package.composition.mutableTrack(compatibleWith: assetTrack) {
            return track
        }*/
        
        let track = package.composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        return track
    }
    
    private func getCompositionAudioTrack(assetTrack: AVAssetTrack) -> AVMutableCompositionTrack? {
        if let track = package.composition.mutableTrack(compatibleWith: assetTrack) {
            return track
        }
        let track = package.composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        return track
    }
}

//MARK:- Private Insert Track
extension LHVideoMergeCommand {
    private func insertVideoTrackToComposition(videoTrack:AVAssetTrack, videoDuration: CMTime) -> AVMutableCompositionTrack? {
        guard let compositionTrack = getCompositionVideoTrack(assetTrack: videoTrack) else {
            //TODO: 错误处理
            print("无法获取 compositionTrack")
            return nil
        }
        
        do {
            try compositionTrack.insertTimeRange(CMTimeRange.init(start: CMTime.zero, end: videoDuration), of: videoTrack, at: package.totalDuration)
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
            try compositionTrack.insertTimeRange(CMTimeRange.init(start: CMTime.zero, end: videoDuration), of: audioTrack, at: package.totalDuration)
        } catch {
            //TODO:无效视频处理
            print(error)
            return nil
        }
        return compositionTrack
    }
}

//MARK:- Private Instruction
extension LHVideoMergeCommand {
    private func addNewInstruction(newVideoDuration: CMTime, newVideoTrack: AVMutableCompositionTrack, preferredTransform: CGAffineTransform) {
        package.videoTrackTransforms[newVideoTrack] = preferredTransform
        /*
        if let instrunction = package.instructions.first {
            let lastEndTime = instrunction.timeRange.end
            instrunction.timeRange = CMTimeRange.init(start: CMTime.zero, end: CMTimeAdd(instrunction.timeRange.end, newVideoDuration))
            
            let newLayerInstruction = AVMutableVideoCompositionLayerInstruction.init(assetTrack: newVideoTrack)
            /*奇怪，为什么这两个设置都能正常播放*/
            newLayerInstruction.setTransform(preferredTransform, at: lastEndTime)
//            newLayerInstruction.setTransform(preferredTransform, at: newVideoTrack.timeRange.start)
            
            var lasts = instrunction.layerInstructions
            lasts.append(newLayerInstruction)
            instrunction.layerInstructions = lasts
            package.videoComposition.instructions = package.instructions
        }else{
            let newInstruction = AVMutableVideoCompositionInstruction()
            
            newInstruction.timeRange = CMTimeRange.init(start: package.totalDuration, duration: newVideoDuration)
            
            let newLayerInstruction = AVMutableVideoCompositionLayerInstruction.init(assetTrack: newVideoTrack)
            
            newLayerInstruction.setTransform(preferredTransform, at: CMTime.zero)
            newInstruction.layerInstructions = [newLayerInstruction]
            package.instructions.append(newInstruction)
            package.videoComposition.instructions = package.instructions
        }*/
        
        let newInstruction = AVMutableVideoCompositionInstruction()
        newInstruction.backgroundColor = UIColor.init(white: 0, alpha: 0).cgColor
        /*这里可以修改合并的背景颜色*/
//        newInstruction.backgroundColor = UIColor.green.cgColor
        newInstruction.timeRange = CMTimeRange.init(start: package.totalDuration, duration: newVideoDuration)
        
        let newLayerInstruction = AVMutableVideoCompositionLayerInstruction.init(assetTrack: newVideoTrack)
        
        newLayerInstruction.setTransform(preferredTransform, at: CMTime.zero)
        newInstruction.layerInstructions = [newLayerInstruction]
        package.instructions.append(newInstruction)
        package.videoComposition.instructions = package.instructions
    }
}
