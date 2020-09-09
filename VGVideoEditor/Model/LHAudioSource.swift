//
//  LHSound.swift
//  VGVideoEditor
//
//  Created by 周智伟 on 2020/9/5.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit

class LHAudioSource: Equatable {
    public let path: String
    public var volume:Float = 1.0
    public var isLoop = false
    
    init(audioPath: String) {
        path = audioPath
    }
    
    func copySource() -> LHAudioSource {
        let copy = LHAudioSource(audioPath: path)
        return copy
    }
    
    static func == (lhs: LHAudioSource, rhs: LHAudioSource) -> Bool {
        return lhs.path == rhs.path
    }
}
