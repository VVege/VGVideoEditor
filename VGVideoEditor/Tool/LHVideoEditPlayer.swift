//
//  LHVideoEditPlayer.swift
//  VGVideoEditor
//
//  Created by 周智伟 on 2020/9/1.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit
import AVFoundation

protocol LHVideoEditPlayerDelegate:class {
    func preparedToPlay()
    func playerIsPlaying(at time: Double)
}

class LHVideoEditPlayer: NSObject {
    /// layer 的 size 由 LHVideoComposition bgSize决定，不要手动改
    /// 修改位置使用 layer.position
    public let layer = CALayer()
    public weak var delegate: LHVideoEditPlayerDelegate?
    
    private var player: AVPlayer!
    private let playerLayer = AVPlayerLayer()
    private var composition = LHVideoComposition()
    private var currentProcessor = LHVideoCompositionProcessor()
    override init() {
        super.init()
        layer.contentsGravity = .resizeAspectFill
        layer.masksToBounds = true
        player = AVPlayer.init()
        player.addPeriodicTimeObserver(forInterval: CMTime.init(value: 60, timescale: 600), queue: nil) {[weak self] (time) in
            self?.delegate?.playerIsPlaying(at: time.seconds)
        }
        playerLayer.player = player
        layer.addSublayer(playerLayer)
    }
    
    deinit {
        player.removeTimeObserver(self)
        removeItemObserve()
    }
}

//MARK:- Public
extension LHVideoEditPlayer {
    
    public func refresh(composition: LHVideoComposition){
        let oldComposition = self.composition
        self.composition = composition.copyComposition()
        
        if needUpdateItem(old: oldComposition, new: composition) {
            currentProcessor = LHVideoCompositionProcessor()
            currentProcessor.loadCompositionInfo(composition: composition)
            replaceItem(asset: currentProcessor.settingPackage.composition, videoComposition: currentProcessor.settingPackage.videoComposition, audioMix: currentProcessor.settingPackage.audioMix)
        }else{
            let needUpdateAudios = needUpdateAudioVolume(old: oldComposition, new: composition)
            for audio in needUpdateAudios {
                currentProcessor.updateVolume(audio: audio)
            }
            player.currentItem?.audioMix = currentProcessor.settingPackage.audioMix
        }
        
        if needUpdateLayer(old: oldComposition, new: composition) {
            refreshLayer()
        }
    }
    
    public func setCurrentTime(time: Double){
        let cmTime = CMTime.init(value: CMTimeValue(time * 600), timescale: 600)
        player.currentItem?.seek(to: cmTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }
    
    public func play() {
        player.play()
    }
    
    public func pause() {
        player.pause()
    }
}

//MARK:- Private
extension LHVideoEditPlayer {
    private func needUpdateItem(old: LHVideoComposition, new: LHVideoComposition) -> Bool {
        if !old.videos.elementsEqual(new.videos) {
            return true
        }
        if !old.audios.elementsEqual(new.audios) {
            return true
        }
        if old.speed != new.speed {
            return true
        }
        if old.cutRange != new.cutRange {
            return true
        }
        if old.cutMode != new.cutMode {
            return true
        }
        return false
    }
    
    private func needUpdateAudioVolume(old: LHVideoComposition, new: LHVideoComposition) -> [LHAudioSource]{
        var needUpdateVolumeSources:[LHAudioSource] = []
        guard old.audios.elementsEqual(new.audios) else {
            return []
        }
        for (index, newAudio) in new.audios.enumerated() {
            let oldAudio = old.audios[index]
            if oldAudio.volume != newAudio.volume {
                needUpdateVolumeSources.append(newAudio)
            }
        }
        return needUpdateVolumeSources
    }
    
    private func needUpdateLayer(old: LHVideoComposition, new: LHVideoComposition) -> Bool {
        if old.bgColor != new.bgColor {
            return true
        }
        if !old.bgSize.equalTo(new.bgSize) {
            return true
        }
        if old.bgImage != new.bgImage {
            return true
        }
        if old.bgColor != new.bgColor {
            return true
        }
        if old.fillMode != new.fillMode {
            return true
        }
        if old.hasWatermark != new.hasWatermark {
            return true
        }
        return false
    }
}

//MARK:- Private CALayer
extension LHVideoEditPlayer {
    private func refreshLayer() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layer.bounds = CGRect(x: 0, y: 0, width: composition.bgSize.width, height: composition.bgSize.height)
        let videoSize = currentProcessor.settingPackage.videoFrame.size
        let fillMode = composition.fillMode
        var videoWidth = videoSize.width
        var videoHeight = videoSize.height
        let bgWidth = composition.bgSize.width
        let bgHeight = composition.bgSize.height
        
        switch fillMode {
        case .fill:
            let widthScale = bgWidth / videoWidth
            let heightScale = bgHeight / videoHeight
            let maxScale = max(widthScale, heightScale)
            videoWidth = videoWidth * maxScale
            videoHeight = videoHeight * maxScale
        case .fit:
            let widthScale = bgWidth / videoWidth
            let heightScale = bgHeight / videoHeight
            let maxScale = min(widthScale, heightScale)
            videoWidth = videoWidth * maxScale
            videoHeight = videoHeight * maxScale
        }
        playerLayer.bounds = CGRect.init(x: 0, y: 0, width: videoWidth, height: videoHeight)
        playerLayer.position = CGPoint(x: bgWidth/2, y: bgHeight/2)
        
        layer.backgroundColor = composition.bgColor?.cgColor
        layer.contents = composition.bgImage?.cgImage
        CATransaction.commit()
    }
}

//MARK:- Private init Player
extension LHVideoEditPlayer {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status", let status = player.currentItem?.status {
            if status == .readyToPlay {
                delegate?.preparedToPlay()
            }else{
                print(status)
            }
        }
    }
}

//MARK:- Set Player
extension LHVideoEditPlayer {
    private func addItemObserve() {
        player.currentItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new.union(.old), context: nil)
    }
    
    private func removeItemObserve() {
        player.currentItem?.removeObserver(self, forKeyPath: "status")
    }
    
    private func replaceItem(asset: AVAsset, videoComposition: AVVideoComposition?, audioMix: AVAudioMix?) {
        removeItemObserve()
        let item = AVPlayerItem.init(asset: asset)
        item.videoComposition = videoComposition
        item.audioTimePitchAlgorithm = .timeDomain
        item.audioMix = audioMix
        player.replaceCurrentItem(with: item)
        addItemObserve()
    }
}
