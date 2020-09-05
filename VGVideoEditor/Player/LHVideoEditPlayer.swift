//
//  LHVideoEditPlayer.swift
//  VGVideoEditor
//
//  Created by 周智伟 on 2020/9/1.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit
import AVFoundation

class LHVideoEditPlayer: NSObject {
    public var layer: CALayer {
        return playerLayer
    }
    
    private var player: AVPlayer!
    private let playerLayer = AVPlayerLayer()
    private var myComposition: LHVideoComposition!
    init(composition: LHVideoComposition) {
        super.init()
        myComposition = composition
        initAVPlayer()
        playerLayer.player = player
    }
}

//MARK:- Public
extension LHVideoEditPlayer {
    public func refresh() {
        ///TODO:清除监听等操作
        let item = AVPlayerItem.init(asset: myComposition.asset())
        item.videoComposition = myComposition.videoMix()
        player.replaceCurrentItem(with: item)
    }
    
    public func play() {
        player.play()
    }
}

//MARK:- Private
extension LHVideoEditPlayer {
    private func initAVPlayer() {
        NSLog("创建player")
        let item = AVPlayerItem.init(asset: myComposition.asset())
        item.videoComposition = myComposition.videoMix()
        player = AVPlayer.init(playerItem: item)
        item.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new.union(.old), context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status", let status = player.currentItem?.status {
            if status == .readyToPlay {
                NSLog("开始播放")
                player.play()
            }else{
                print(status)
            }
        }
    }
}

