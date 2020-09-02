//
//  LHVideoUtil.swift
//  VGVideoEditor
//
//  Created by 周智伟 on 2020/9/2.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit

enum LHVideoDirection {
    case portrait
    case portraitUpsideDown
    case landscapeRight
    case landscapeLeft
    
    init(transform: CGAffineTransform) {
        if(transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0){
            // 90
            self = .portrait
        }else if(transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0){
            // 270
            self = .portraitUpsideDown
        }else if(transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0){
            // 0
            self = .landscapeRight
        }else if(transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0){
            // 180
            self = .landscapeLeft
        }else {
            self = .landscapeRight
        }
    }
    
    /** 矩阵校正 */
    // x = ax1 + cy1 + tx
    // y = bx1 + dy2 + ty
    func makeAdjustTransform(natureSize: CGSize) -> CGAffineTransform {
        switch self {
        case .portrait:
            return CGAffineTransform.init(a: 0, b: 1, c: -1, d: 0, tx: natureSize.height, ty: 0)
        case .portraitUpsideDown:
            return CGAffineTransform.init(a: 0, b: -1, c: 1, d: 0, tx: -natureSize.height, ty: 2 * natureSize.width)
        case .landscapeLeft:
            return CGAffineTransform.init(a: -1, b: 0, c: 0, d: -1, tx: natureSize.width, ty: natureSize.height)
        case .landscapeRight:
            return CGAffineTransform.identity
        }
    }
}
