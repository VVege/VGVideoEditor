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
    private let bgColor: CGColor?
    private let bgImage: CGImage?
    private let fillMode: LHVideoFillMode
    private let renderRatio: LHVideoRenderRatio
    init(settingPackage: LHVideoSettingPackage, newVideoSource: LHVideoSource, videoBgColor: CGColor?, videoBgImage: CGImage?, videoFillMode: LHVideoFillMode, videoRenderRatio: LHVideoRenderRatio) {
        package = settingPackage
        videoSource = newVideoSource
        bgColor = videoBgColor
        bgImage = videoBgImage
        fillMode = videoFillMode
        renderRatio = videoRenderRatio
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
            
            if direction == .portrait || direction == .portraitUpsideDown {
                newVideoSize = CGSize(width: newVideoSize.height, height: newVideoSize.width)
            }
            
            /// 旋转角度适配
            /*
            let adjustDirectionTransform = direction.makeAdjustTransform(natureSize: newVideoSize)
            */
            if package.isEmpty() {
                var renderSize = newVideoSize
                switch renderRatio {
                case .original:
                    break
                case .r16_9:
                    let height = renderSize.height
                    let width = height * 16.0/9.0
                    renderSize = CGSize(width: width, height: height)
                case .r9_16:
                    let width = renderSize.width
                    let height = width * 16.0/9.0
                    renderSize = CGSize(width: width, height: height)
                case .r3_4:
                    let width = renderSize.width
                    let height = width * 4.0/3.0
                    renderSize = CGSize(width: width, height: height)
                case .r4_3:
                    let height = renderSize.height
                    let width = height * 4.0/3.0
                    renderSize = CGSize(width: width, height: height)
                case .r1_1:
                    let width = max(renderSize.width, renderSize.height)
                    let height = width
                    renderSize = CGSize(width: width, height: height)
                case .r6_7:
                    let width = renderSize.width
                    let height = width * 7.0/6.0
                    renderSize = CGSize(width: width, height: height)
                case .r1_2:
                    let width = renderSize.width
                    let height = width * 2.0
                    renderSize = CGSize(width: width, height: height)
                case .r2_1:
                    let height = renderSize.height
                    let width = height * 2.0
                    renderSize = CGSize(width: width, height: height)
                }
                package.videoComposition.renderSize = renderSize
                package.composition.naturalSize = renderSize
                // 30fps
                package.videoComposition.frameDuration = CMTime.init(value: 1, timescale: 30)
                /// 更新package
                package.videoSize = renderSize
                
                let transform = generateTransform(newVideoSize: newVideoSize, renderSize: renderSize, natureTransform: newVideoTrack.preferredTransform, fillMode: fillMode)

                addNewInstruction(newVideoDuration: videoDuration, newVideoTrack: newVideoMergedTrack, preferredTransform:transform)
            }else{
                let renderSize = package.videoComposition.renderSize
                
                let transform = generateTransform(newVideoSize: newVideoSize, renderSize: renderSize, natureTransform: newVideoTrack.preferredTransform, fillMode: fillMode)
                
                addNewInstruction(newVideoDuration: videoDuration, newVideoTrack: newVideoMergedTrack, preferredTransform: transform)
            }
        }else{
            package.error[.video] = "视频无效，未发现视频轨道"
        }
        
        //插入音频轨道
        if let newAudioTrack = tuple.audioTrack, let newAudioMergedTrack = insertAudioTrackToComposition(audioTrack: newAudioTrack, videoDuration: videoDuration) {
            package.videoOriginalAudioTracks[videoSource.path] = newAudioMergedTrack
            let inputParameter = AVMutableAudioMixInputParameters(track: newAudioMergedTrack)
            inputParameter.setVolume(Float(videoSource.volume * 0.7), at: CMTime.zero)
            inputParameter.audioTimePitchAlgorithm = .timeDomain
            package.audioMixParameters.append(inputParameter)
            package.audioMix.inputParameters = package.audioMixParameters
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
        //暂时都使用新轨道
        /*
        if let track = package.composition.mutableTrack(compatibleWith: assetTrack) {
            return track
        }*/
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
                
        let newInstruction = LHCustomCompositionInstruction()
        newInstruction.renderSize = package.videoSize
        newInstruction.bgImage = bgImage
        if let color = bgColor {
            newInstruction.backgroundColor = CIColor.init(cgColor: color)
        }
        newInstruction.timeRange = CMTimeRange.init(start: package.totalDuration, duration: newVideoDuration)
        
        let newLayerInstruction = LHCustomCompositionLayerInstruction.init()
        newLayerInstruction.trackID = newVideoTrack.trackID
        newInstruction.layerInstructions = [newLayerInstruction]
        package.instructions.append(newInstruction)
        package.videoComposition.instructions = package.instructions
    }
    
    private func generateTransform(newVideoSize:CGSize, renderSize:CGSize, natureTransform: CGAffineTransform, fillMode: LHVideoFillMode) -> CGAffineTransform {
        
        var scale:CGFloat = 1
        switch fillMode {
        case .fill:
            scale = max(renderSize.width/newVideoSize.width, renderSize.height/newVideoSize.height)
        case .fit:
            scale = min(renderSize.width/newVideoSize.width, renderSize.height/newVideoSize.height)
        }
        
        // 移至中心点
        let translate = CGPoint.init(x: (renderSize.width - newVideoSize.width * scale) * 0.5, y: (renderSize.height - newVideoSize.height * scale) * 0.5)
        
        let preferredTransfrom = CGAffineTransform.init(a: natureTransform.a * scale, b: natureTransform.b * scale, c: natureTransform.c * scale, d: natureTransform.d * scale, tx: natureTransform.tx * scale + translate.x, ty: natureTransform.ty * scale + translate.y)
        return preferredTransfrom
    }
}
