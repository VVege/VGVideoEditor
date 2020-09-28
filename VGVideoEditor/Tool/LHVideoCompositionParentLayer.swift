//
//  LHVideoCompositionParentLayer.swift
//  LHVideoEditorDemo
//
//  Created by 伟哥 on 2020/9/11.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit

class LHVideoCompositionParentLayer: CALayer {
    
    public var size:CGSize = CGSize.zero
    
    public var videoOriginalSize:CGSize = CGSize.zero
    public var videoFillMode: LHVideoFillMode = .fit
    
    public var hasWaterMark:Bool = false
    public var bgColor:CGColor?
    public var bgImage:CGImage?
    
    private var videoLayer:CALayer!
    private var waterMarkLayer = CALayer()
    
    init(videoLayer: CALayer) {
        super.init()
        self.videoLayer = videoLayer
        addSublayer(videoLayer)
        contentsGravity = .resizeAspectFill
        masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK:- Public
extension LHVideoCompositionParentLayer {
    
    public func refreshLayer() {
        var videoLayerWidth = videoOriginalSize.width
        var videoLayerHeight = videoOriginalSize.height
        let bgWidth = size.width == 0 ? videoLayerWidth : size.width
        let bgHeight = size.height == 0 ? videoLayerHeight : size.height
        
        var scale:CGFloat = 1
        switch videoFillMode {
        case .fill:
            let widthScale = bgWidth / videoLayerWidth
            let heightScale = bgHeight / videoLayerHeight
            let maxScale = max(widthScale, heightScale)
            scale = maxScale
            videoLayerWidth = videoLayerWidth * maxScale
            videoLayerHeight = videoLayerHeight * maxScale
        case .fit:
            let widthScale = bgWidth / videoLayerWidth
            let heightScale = bgHeight / videoLayerHeight
            let minScale = min(widthScale, heightScale)
            scale = minScale
            videoLayerWidth = videoLayerWidth * minScale
            videoLayerHeight = videoLayerHeight * minScale
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        videoLayer.backgroundColor = UIColor.init(white: 0, alpha: 0).cgColor
        frame = CGRect(x: 0, y: 0, width: bgWidth, height: bgHeight)
        videoLayer.frame = CGRect(x: 0, y: 0, width: videoOriginalSize.width, height: bgHeight)
//        videoLayer.frame = CGRect(x: 0, y: 0, width: videoOriginalSize.width, height: videoOriginalSize.height)
        
//        videoLayer.frame = CGRect.init(x: 0, y: 0, width: videoOriginalSize.width, height: videoOriginalSize.height)
//        videoLayer.setAffineTransform(CGAffineTransform.init(scaleX: scale, y: scale))

//        videoLayer.position = CGPoint(x: bgWidth/2, y: bgHeight/2)
        
        backgroundColor = bgColor
        contents = bgImage
        CATransaction.commit()
    }
    
    /*
    public func refreshLayer() {
        var videoLayerWidth = videoOriginalSize.width
        var videoLayerHeight = videoOriginalSize.height
        let bgWidth = size.width == 0 ? videoLayerWidth : size.width
        let bgHeight = size.height == 0 ? videoLayerHeight : size.height
        
        switch videoFillMode {
        case .fill:
            let widthScale = bgWidth / videoLayerWidth
            let heightScale = bgHeight / videoLayerHeight
            let maxScale = max(widthScale, heightScale)
            videoLayerWidth = videoLayerWidth * maxScale
            videoLayerHeight = videoLayerHeight * maxScale
        case .fit:
            let widthScale = bgWidth / videoLayerWidth
            let heightScale = bgHeight / videoLayerHeight
            let maxScale = min(widthScale, heightScale)
            videoLayerWidth = videoLayerWidth * maxScale
            videoLayerHeight = videoLayerHeight * maxScale
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        frame = CGRect(x: 0, y: 0, width: videoOriginalSize.width, height: videoOriginalSize.height)
        videoLayer.frame = CGRect(x: 50, y: 50, width: videoOriginalSize.width - 100, height: videoOriginalSize.height - 100)
//        videoLayer.anchorPoint = CGPoint(x: bounds.width/2, y: bounds.height/2)
//        videoLayer.setAffineTransform(CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5))
        
        /*
        bounds = CGRect(x: 0, y: 0, width: bgWidth, height: bgHeight)
        
        videoLayer.bounds = CGRect.init(x: 0, y: 0, width: videoLayerWidth, height: videoLayerHeight)
        videoLayer.position = CGPoint(x: bgWidth/2, y: bgHeight/2)
        */
        backgroundColor = bgColor
        contents = bgImage
        CATransaction.commit()
    }*/
}
