//
//  LHVideoEditPlayer.swift
//  VGVideoEditor
//
//  Created by 周智伟 on 2020/9/1.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit
import AVFoundation

/// 先只合并视频
/// 音频采用原来的
class LHVideoEditPlayer: NSObject {
    /// layer 的 size 由 LHVideoComposition bgSize决定，不要手动改
    /// 修改位置使用 layer.position
    public let layer = CALayer()
    
    private var player: AVPlayer!
    private let playerLayer = AVPlayerLayer()
    private var currentTime:Double = 0
    
    init(asset: AVAsset, videoComposition: AVVideoComposition?) {
        super.init()
        let item = AVPlayerItem.init(asset: asset)
        item.videoComposition = videoComposition
        player = AVPlayer.init(playerItem: item)
        item.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new.union(.old), context: nil)
        item.audioTimePitchAlgorithm = .timeDomain
        playerLayer.player = player
        layer.addSublayer(playerLayer)
    }
    
    deinit {
        player.currentItem?.removeObserver(self, forKeyPath: "status")
    }
}

//MARK:- Public
extension LHVideoEditPlayer {
    
    public func replaceItem() {
        
    }
    
    public func refresh(composition: LHVideoComposition){
        
//        let current = self.composition

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        /// TODO:检测sound
//        if composition.rate != current.rate {
//            player.rate = Float(composition.rate)
//        }
//        if composition.bgColor != current.bgColor {
            layer.backgroundColor = composition.bgColor?.cgColor
//        }
//        if composition.bgImage != current.bgImage {
            layer.contents = composition.bgImage?.cgImage
//        }
//        if !composition.videoFrame.equalTo(current.videoFrame) {
            playerLayer.frame = composition.videoFrame
//        }
//        if !composition.bgSize.equalTo(current.bgSize) {
            layer.frame = CGRect.init(x: 0, y: 0, width: composition.bgSize.width, height: composition.bgSize.height)
//        }
//        if composition.fillMode != current.fillMode {
//
//        }
        CATransaction.commit()
    }
    
    public func setCurrentTime(time: Double){
        let cmTime = CMTime.init(value: CMTimeValue(time * 600), timescale: 600)
        player.currentItem?.seek(to: cmTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }
}

//MARK:- Private init Player
extension LHVideoEditPlayer {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status", let status = player.currentItem?.status {
            if status == .readyToPlay {
                NSLog("开始播放")
                player.play()
                
//                testPlay()
            }else{
                print(status)
            }
        }
    }
    
    private func testPlay() {
        let timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) {[weak self] (_) in
            if let nowTime = self?.currentTime, let player = self?.player {
                let seekTime = CMTime.init(value: CMTimeValue(nowTime * 600), timescale: 600)
                player.currentItem?.seek(to: seekTime)
                self?.currentTime += 0.04
            }
        }
        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
    }
}

//MARK:- Set Player
extension LHVideoEditPlayer {
     
}
