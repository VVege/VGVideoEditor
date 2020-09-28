//
//  LHVideoWatermarkGenerator.swift
//  LHSP
//
//  Created by 周智伟 on 2020/9/17.
//  Copyright © 2020 梁嘉豪. All rights reserved.
//

import UIKit

class LHVideoWatermarkGenerator: NSObject {
    
    class func generateWatermark(videoSize: CGSize) -> CALayer {
        let image = UIImage.init(named: "video_edit_watermark")
        let imageSize = image?.size ?? CGSize(width: 200, height: 200)
        let imageRatio = imageSize.width / imageSize.height
        
        let imageWidth:CGFloat = min(videoSize.width, videoSize.height) * 0.4
        let imageHeight:CGFloat = imageWidth / imageRatio
        
        let layer = CALayer()
        layer.frame = CGRect(x: videoSize.width - imageWidth, y: videoSize.height - imageHeight, width: imageWidth, height: imageHeight)
        layer.contents = image?.cgImage
        return layer
    }
}
