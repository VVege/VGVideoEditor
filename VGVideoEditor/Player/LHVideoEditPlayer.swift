//
//  LHVideoEditPlayer.swift
//  VGVideoEditor
//
//  Created by 周智伟 on 2020/9/1.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit
import AVFoundation

class LHVideoEditPlayer {
    public var layer: CALayer {
        return playerLayer
    }
    
    public let rootSource:LHVideoRootSource
    
    private var player: AVPlayer!
    private let playerLayer = AVPlayerLayer()
    
    init(source: LHVideoRootSource) {
        rootSource = source
        initAVPlayer()
        playerLayer.player = player
    }
}

//MARK:- Public
extension LHVideoEditPlayer {
    public func refresh() {
        ///TODO:清除监听等操作
        let item = AVPlayerItem.init(asset: rootSource.asset())
        player.replaceCurrentItem(with: item)
    }
    
    public func play() {
        player.play()
    }
}

//MARK:- Private
extension LHVideoEditPlayer {
    private func initAVPlayer() {
        let item = AVPlayerItem.init(asset: rootSource.asset())
        player = AVPlayer.init(playerItem: item)
    }
}
