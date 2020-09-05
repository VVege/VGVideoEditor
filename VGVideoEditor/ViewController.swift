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
    private var processor: LHVideoCompositionProcessor!
    private var exporter: LHVideoExporter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        
        let composition = LHVideoComposition()
        processor = LHVideoCompositionProcessor.init(model: composition)
        
        
        let path = Bundle.main.path(forResource: "test2", ofType: "mp4")
        let source = LHVideoSource.init(videoPath: path!)
        
        let path1 = Bundle.main.path(forResource: "test3", ofType: "mp4")
        let source1 = LHVideoSource.init(videoPath: path1!)
        
        NSLog("开始合并")
        processor.merge(video: source)
        processor.merge(video: source1)
        NSLog("完成合并")
        NSLog("开始裁剪")
        let stayRange = CMTimeRange.init(start: CMTime.init(value: 8 * 600, timescale: 600), end: CMTime.init(value: 16 * 600, timescale: 600))
        processor.cut(range: stayRange)
        NSLog("结束裁剪")
        print("toolDuration\(processor.settingPackage.totalDuration)")
        export()
//        play()
//        otherExport()
    }
    
    func play() {
        player = LHVideoEditPlayer.init(settingPackage: processor.settingPackage)
        player.layer.frame = CGRect(x: 100, y: 100, width: 200, height: 200)
        view.layer.addSublayer(player.layer)
    }
    
    func otherExport() {
        exporter = LHVideoExporter.init(processer: processor)
        view.layer.addSublayer(exporter.layer)
        exporter.export()
    }
    
    func export() {
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
        }
    }
}

