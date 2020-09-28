//
//  LHSound.swift
//  VGVideoEditor
//
//  Created by 周智伟 on 2020/9/5.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit

enum LHAudioSourceType {
    case record
    case bgMusic
}

class LHAudioSource: Equatable {
    
    public let path:String
    
    public var volume:Double = 1.0
    public var isLoop = false
    public var type: LHAudioSourceType = .record
    
    init(audioPath: String) {
        path = audioPath
    }
    
    func copySource() -> LHAudioSource {
        let copy = LHAudioSource(audioPath: path)
        copy.volume = volume
        copy.isLoop = isLoop
        copy.type = type
        return copy
    }
    
    ///不判断音量volume
    ///其他属性改变需要重新生成track
    ///volume不需要重新生成track
    static func == (lhs: LHAudioSource, rhs: LHAudioSource) -> Bool {
        return (lhs.path == rhs.path && lhs.isLoop == rhs.isLoop && lhs.type == rhs.type)
    }
}
