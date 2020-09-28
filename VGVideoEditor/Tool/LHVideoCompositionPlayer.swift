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
    func playerRefreshFinish(isReset:Bool, errorMessage: String?)
    func playerIsPlaying(at time: Double)
    func playerDidPlayToEndTime()
}

class LHVideoCompositionPlayerLayer: CALayer {
    private var videoLayer: CALayer?
    
    override var frame: CGRect {
        didSet {
            super.frame = frame
            videoLayer?.frame = bounds
        }
    }
    
    fileprivate func addVideoLayer(layer: CALayer) {
        videoLayer = layer
        videoLayer?.frame = bounds
        insertSublayer(layer, at: 0)
    }
    
    fileprivate func setVideoLayerHidden(isHidden: Bool, isAnimate: Bool) {
        CATransaction.begin()
        CATransaction.setDisableActions(!isAnimate)
        videoLayer?.isHidden = isHidden
        CATransaction.commit()
    }

}

private typealias PlayableLoadClosure = (_ flag:Bool)->()

class LHVideoCompositionPlayer: NSObject {

    public let layer = LHVideoCompositionPlayerLayer()
    
    public weak var delegate: LHVideoEditPlayerDelegate?
    
    private var player: AVPlayer!
    private let playerLayer = AVPlayerLayer()
    private var composition = LHVideoComposition()
    private var currentProcessor: LHVideoCompositionProcessor!
    private var imageGenerator: AVAssetImageGenerator!
    private var timeObserve:Any?
    private var seekToTime: Double = 0
    
    private var isRefreshing = false
    override init() {
        super.init()
        player = AVPlayer.init()
        playerLayer.player = player
        layer.addVideoLayer(layer: playerLayer)
    } 
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        removePlayProgressObserve()
        removeItemObserve()
    }
}

//MARK:- Public
extension LHVideoCompositionPlayer {
    
    public func refresh(composition: LHVideoComposition){
        
        if isRefreshing {
            print("error: 播放器正在刷新")
            return
        }
        
        isRefreshing = true
        let oldComposition = self.composition
        self.composition = composition.copyComposition()
        
        if needUpdateItem(old: oldComposition, new: composition) {
            currentProcessor = LHVideoCompositionProcessor(composition: self.composition)
            if let errorMessage = currentProcessor.error() {
                finishRefresh(isReset: false, errorMessage: errorMessage)
            }else{
                if needTempHiddenVideoLayer(old: oldComposition, new: composition){
                    layer.setVideoLayerHidden(isHidden: true, isAnimate: false)
                }
                loadAssetToPlayable(asset: currentProcessor.settingPackage.composition) {[weak self] (success) in
                    guard let weakSelf = self else {
                        return
                    }
                    if success {
                        weakSelf.replaceItem(asset: weakSelf.currentProcessor.settingPackage.composition, videoComposition: weakSelf.currentProcessor.settingPackage.videoComposition, audioMix: weakSelf.currentProcessor.settingPackage.audioMix)
                    }else{
                        weakSelf.finishRefresh(isReset: false, errorMessage: "加载资源失败")
                    }
                }
            }
        }else{
            /// 检测音视频音量更新
            let needUpdateAudios = needUpdateAudioVolume(old: oldComposition, new: composition)
            
            if needUpdateAudios.count > 0 {
                for audio in needUpdateAudios {
                    currentProcessor.updateVolume(audio: audio)
                }
                player.currentItem?.audioMix = currentProcessor.settingPackage.audioMix
            }
    
            finishRefresh(isReset: false, errorMessage: nil)
        }
    }
    
    public func setCurrentTime(time: Double){
        let cmTime = CMTime.init(value: CMTimeValue(time * 600), timescale: 600)
        player.currentItem?.seek(to: cmTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        seekToTime = time
    }
    
    public func play() {
        ///TODO:精度存在问题
        let tolerace = duration() - player.currentTime().seconds
        
        if fabs(tolerace) < 0.002 {
            setCurrentTime(time: 0)
        }
        player.play()
        addPlayProgressObserve()
    }
    
    public func pause() {
        player.pause()
        removePlayProgressObserve()
    }
    
    public func duration() ->Double {
        return currentProcessor.settingPackage.totalDuration.seconds
    }
    
    public func origanlSize() -> CGSize {
        return currentProcessor.settingPackage.videoSize
    }
    
    public func isPlaying() -> Bool {
        return player.rate > 0
    }
    
    public func setVolume(volume: Float) {
        player.volume = volume
    }
    
    public func playerIsRefreshing() -> Bool {
        return isRefreshing
    }
}

//MARK:- Private
extension LHVideoCompositionPlayer {
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
        if old.fillMode != new.fillMode {
            return true
        }
        if old.renderRatio != new.renderRatio {
            return true
        }
        if old.bgColor != new.bgColor {
            return true
        }
        
        return false
    }
    
    /// 是否隐藏videoLayer
    /// 一些时候需要判断是否隐藏videoLayer，例如修改背景比例时如果修改frame，则会有闪动。
    /// 暂时的隐藏，在加载好的时候会显示
    private func needTempHiddenVideoLayer(old: LHVideoComposition, new: LHVideoComposition) -> Bool {
        return old.renderRatio != new.renderRatio
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
   
    private func finishRefresh(isReset: Bool, errorMessage: String?) {
        isRefreshing = false
        layer.setVideoLayerHidden(isHidden: false, isAnimate: true)
        delegate?.playerRefreshFinish(isReset: isReset, errorMessage: errorMessage)
    }
}

//MARK:- Private init Player
extension LHVideoCompositionPlayer {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status", let status = player.currentItem?.status {
            if status == .readyToPlay {
                self.finishRefresh(isReset: true, errorMessage: nil)
            }else if status == .failed{
                self.finishRefresh(isReset: false, errorMessage: player.currentItem?.error?.localizedDescription)
            }
        }
    }
}

//MARK:- Set Player
extension LHVideoCompositionPlayer {
    private func addItemObserve() {
        player.currentItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new.union(.old), context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    private func removeItemObserve() {
        player.currentItem?.removeObserver(self, forKeyPath: "status")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    private func replaceItem(asset: AVAsset, videoComposition: AVVideoComposition?, audioMix: AVAudioMix?) {
        seekToTime = 0
        removeItemObserve()
        let item = AVPlayerItem.init(asset: asset,automaticallyLoadedAssetKeys: nil)
        item.videoComposition = videoComposition
        item.audioMix = audioMix
        player.replaceCurrentItem(with: item)
        addItemObserve()
    }
    
    private func loadAssetToPlayable(asset: AVAsset, finish: @escaping PlayableLoadClosure) {
        let key = "playable"
        asset.loadValuesAsynchronously(forKeys: [key]) {
            var error: NSError?
            let status = asset.statusOfValue(forKey: key, error: &error)
            switch status {
            case .loaded:
                DispatchQueue.main.async {
                    finish(true)
                }
            case .failed:
                DispatchQueue.main.async {
                    finish(false)
                }
            case .loading:break
            case .unknown:break
            case .cancelled:
                DispatchQueue.main.async {
                    finish(false)
                }
            @unknown default:
                break
            }
        }
    }
    
    private func addPlayProgressObserve() {
        if timeObserve != nil {
            return
        }
        timeObserve = player.addPeriodicTimeObserver(forInterval: CMTime.init(value: 20, timescale: 600), queue: nil) {[weak self] (time) in
            let seconds = time.seconds
            let seekToTime = self?.seekToTime ?? 0
            /// 由于回调精度问题，seekToTime后，这里依然会返回seekTime之前的时间
            /// 这里过滤
            if seconds > seekToTime {
                self?.delegate?.playerIsPlaying(at: seconds)
            }
        }
    }
    
    private func removePlayProgressObserve() {
        if let observe = timeObserve {
            player.removeTimeObserver(observe)
            timeObserve = nil
        }
    }
}

//MARK:- Notification Event
extension LHVideoCompositionPlayer {
    @objc
    private func playerItemDidPlayToEndTime() {
        delegate?.playerDidPlayToEndTime()
    }
}
