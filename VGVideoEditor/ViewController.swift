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
    private var rootSource: LHVideoRootSource!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        let transform1 = CGAffineTransform.identity
        let transform2 = transform1.translatedBy(x: 10, y: 10)
        let transform3 = transform2.scaledBy(x: 2, y: 2)
        print("fff")
        /*
        let path = Bundle.main.path(forResource: "test5", ofType: "mp4")
        rootSource = LHVideoRootSource.init(videoPath: path!)
        
        let path1 = Bundle.main.path(forResource: "test6", ofType: "mp4")
        let subSource = LHVideoSubSource.init(videoPath: path1!)
        
        rootSource.append(subSource: subSource)
        export()
 */
//        play()
    }
    
    func play() {
        player = LHVideoEditPlayer.init(source: rootSource)
        player.layer.frame = CGRect(x: 100, y: 100, width: 200, height: 200)
        view.layer.addSublayer(player.layer)
        player.play()
    }
    
    func export() {
        if FileManager.default.fileExists(atPath: filePath) {
            try? FileManager.default.removeItem(atPath: filePath)
        }
        exportSession = AVAssetExportSession.init(asset: rootSource.asset(), presetName: AVAssetExportPresetHighestQuality)
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.videoComposition = rootSource.videoSettings()
        exportSession.timeRange = CMTimeRange.init(start: CMTime.zero, end: rootSource.asset().duration)
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
        }
    }
}

