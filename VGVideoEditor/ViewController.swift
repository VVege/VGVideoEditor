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

    private var player:LHVideoEditPlayer!
    private var exportSession: AVAssetExportSession!
    private var exporter: LHVideoExporter!
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
        audio.volume = 0.5
        audio.isLoop = true
        composition = LHVideoComposition()
        composition.videos = [source, source1, source2]
        composition.audios = [audio]
        composition.bgSize = CGSize(width: 300, height: 300)
        composition.fillMode = .fit
        composition.bgColor = UIColor.red
        play()
        
//        export()
    }
    
    func play() {
        player = LHVideoEditPlayer.init()
        player.refresh(composition: composition)
        player.delegate = self
        player.layer.position = CGPoint(x: view.bounds.width/2, y: view.bounds.height/2)
        view.layer.addSublayer(player.layer)
    }
    
    func export() {
        /*
        print(filePath)
        if FileManager.default.fileExists(atPath: filePath) {
            try? FileManager.default.removeItem(atPath: filePath)
        }
        exportSession = AVAssetExportSession.init(asset: processor.settingPackage.composition, presetName: AVAssetExportPresetHighestQuality)
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.videoComposition = processor.settingPackage.videoComposition
        exportSession.timeRange = CMTimeRange.init(start: CMTime.zero, end: processor.settingPackage.totalDuration)
        exportSession.outputURL = URL.init(fileURLWithPath: filePath)
        exportSession.outputFileType = .mp4
        
        NSLog("--开始导出")
        exportSession.exportAsynchronously { [weak self] in
            guard let session = self?.exportSession else {
                return
            }
            switch session.status {
            case .unknown:
                print("unknown")
            case .waiting:
                 print("waiting")
            case .exporting:
                 print("exporting")
            case .completed:
                 print("completed")
                NSLog("--完成导出")
            case .failed:
                print("failed")
                if let error = session.error {
                    print(error)
                }
            case .cancelled:
                 print("cancelled")
            @unknown default:
                 print("default")
            }
        }*/
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
    func preparedToPlay() {
        player.play()
    }
    
    func playerIsPlaying(at time: Double) {
        
    }
}
