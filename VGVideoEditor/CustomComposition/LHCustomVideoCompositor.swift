//
//  LHCustomVideoCompositor.swift
//  LHVideoEditorDemo
//
//  Created by 周智伟 on 2020/9/21.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit
import AVFoundation

class LHCustomVideoCompositor: NSObject, AVVideoCompositing{
    var sourcePixelBufferAttributes: [String : Any]? {
        return ["\(kCVPixelBufferPixelFormatTypeKey)": kCVPixelFormatType_32BGRA]
    }
    
    var requiredPixelBufferAttributesForRenderContext: [String : Any] = ["\(kCVPixelBufferPixelFormatTypeKey)": kCVPixelFormatType_32BGRA]
    
    func renderContextChanged(_ newRenderContext: AVVideoCompositionRenderContext) {
        
    }
    
    func startRequest(_ asyncVideoCompositionRequest: AVAsynchronousVideoCompositionRequest) {
        
        guard let instruction = asyncVideoCompositionRequest.videoCompositionInstruction as? LHCustomCompositionInstruction, let layerInstruction = instruction.layerInstructions.first else {
            return
        }
        
        let trackId = layerInstruction.trackID
        let sourcePixelBuffer = asyncVideoCompositionRequest.sourceFrame(byTrackID: trackId)
        guard let buffer = sourcePixelBuffer else {
            return
        }
        
        // if we have our expected instructions
        if let image = instruction.bgImage{
            // lock the buffer, create a new context and draw the watermark image
            CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags.readOnly)
            let newContext = CGContext.init(data: CVPixelBufferGetBaseAddress(buffer), width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer), space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            ///TODO:如何传frame
            ///TODO:如何将背景画在下面
            ///TODO:那动态模糊呢
            newContext?.draw(image, in: CGRect.init(x: 0, y: 0, width: instruction.renderSize.width, height: instruction.renderSize.height))
            CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags.readOnly)
        }
        asyncVideoCompositionRequest.finish(withComposedVideoFrame: buffer)
    }
}

//MARK:- Private
extension LHCustomCompositionInstruction {
}
