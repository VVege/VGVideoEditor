//
//  ViewController.swift
//  VGVideoEditor
//
//  Created by 周智伟 on 2020/9/1.
//  Copyright © 2020 vege. All rights reserved.
//

import UIKit
import AVFoundation

let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!

let filePath = documentPath + "/test.mp4"

class ViewController: UIViewController {

    private var player:LHVideoCompositionPlayer!
    private var composition :LHVideoComposition!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        
        let path = Bundle.main.path(forResource: "test1", ofType: "mp4")
        let source = LHVideoSource.init(videoPath: path!)
        
        let path1 = Bundle.main.path(forResource: "test2", ofType: "mp4")
        let source1 = LHVideoSource.init(videoPath: path1!)
        
        let path2 = Bundle.main.path(forResource: "test3", ofType: "mp4")
        let source2 = LHVideoSource.init(videoPath: path2!)
        
        let sound1 = Bundle.main.path(forResource: "sound1", ofType: "mp3")
        let audio = LHAudioSource.init(audioPath: sound1!)
        audio.volume = 0.0
        audio.isLoop = true
        composition = LHVideoComposition()
        composition.videos = [source, source1, source2]
        composition.fillMode = .fit
        composition.bgColor = UIColor.red
        composition.bgImage = UIImage.init(named: "cat")
        play()
        
    }
    
    func play() {
        player = LHVideoCompositionPlayer.init()
        player.refresh(composition: composition)
        player.delegate = self
        player.layer.position = CGPoint(x: view.bounds.width/2, y: view.bounds.height/2)
        view.layer.addSublayer(player.layer)
    }
}

extension ViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        /*
        composition.cutRange = 0...13
        composition.cutMode = .abandon
        composition.speed = 0.5
 */
//        composition.fillMode = .fill
        composition.audios.first?.volume = 1.0
        player.refresh(composition: composition)
    }
}

extension ViewController: LHVideoEditPlayerDelegate {
    func playerRefreshFinish(isReset: Bool, errorMessage: String?) {
        
    }
    
    func playerDidPlayToEndTime() {
        
    }

    func playerIsPlaying(at time: Double) {
        
    }
}
