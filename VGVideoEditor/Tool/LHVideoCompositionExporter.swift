//
//  LHVideoCompositionExporter.swift
//  LHSP
//
//  Created by 周智伟 on 2020/9/10.
//  Copyright © 2020 梁嘉豪. All rights reserved.
//

import UIKit
import AVFoundation

private let exportFilePath = (documentPath ?? "") + "/LHVideoCompositionExporter.mp4"

enum ExportErrorType {
    case sessionError
    case userCancel
    case enterBackgroundCancel
}

protocol LHVideoCompositionExporterDelegate:class {
    func exporterFail(errorMessage: String, errorType: ExportErrorType)
    func exporterSuccess(filePath: String)
    func exporterProgress(progress: Double)
}

class LHVideoCompositionExporter: NSObject {
    
    public weak var delegate: LHVideoCompositionExporterDelegate?
    
    private var exportSession: AVAssetExportSession!
    private var timer:Timer?
    private var processor: LHVideoCompositionProcessor!
    
    private var triggerError: ExportErrorType?
    
    override init() {
        super.init()
        addNotification()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK:- Public
extension LHVideoCompositionExporter {
    
    public func prepareForEstimatingDataSize(composition: LHVideoComposition) {
        processor = LHVideoCompositionProcessor(composition: composition, loadAnimationTool: true)
    }
    
    public func estimateExportDataSize(quality: LHVideoQuality) -> Int64? {
        let exportSession = AVAssetExportSession.init(asset: processor.settingPackage.composition, presetName: quality.exportPreset())
        exportSession?.shouldOptimizeForNetworkUse = true
        exportSession?.videoComposition = processor.settingPackage.videoComposition
        exportSession?.timeRange = CMTimeRange.init(start: CMTime.zero, end: processor.settingPackage.totalDuration)
        exportSession?.outputURL = URL.init(fileURLWithPath: exportFilePath)
        exportSession?.outputFileType = .mp4
        return exportSession?.estimatedOutputFileLength
    }
    
    public func export(composition: LHVideoComposition) {
        startExportSession(composition: composition)
        startTimer()
    }
    
    public func cancelExporting() {
        triggerError = .userCancel
        exportSession.cancelExport()
    }
}

//MARK:- Private
extension LHVideoCompositionExporter {
    
    private func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(enterBackgroundNotificationEvent), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    private func startTimer() {
        timer = Timer.init(timeInterval: 0.2, target: self, selector: #selector(timerEvent), userInfo: nil, repeats: true)
        if let timer = timer {
            RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
        }
    }
    
    private func endTimer() {
        timer?.invalidate()
    }
    
    private func finish(errorMessage: String?, errorType: ExportErrorType?) {
        if let errorType = errorType {
            delegate?.exporterFail(errorMessage: errorMessage ?? "未知错误", errorType: errorType)
        }else{
            delegate?.exporterSuccess(filePath: exportFilePath)
        }
        endTimer()
    }
    
    private func startExportSession(composition: LHVideoComposition) {
        triggerError = nil
        processor = LHVideoCompositionProcessor(composition: composition, loadAnimationTool: composition.hasWatermark)
        
        if FileManager.default.fileExists(atPath: exportFilePath) {
            try? FileManager.default.removeItem(atPath: exportFilePath)
        }
        
        exportSession = AVAssetExportSession.init(asset: processor.settingPackage.composition, presetName: composition.quality.exportPreset())
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.videoComposition = processor.settingPackage.videoComposition
        exportSession.timeRange = CMTimeRange.init(start: CMTime.zero, end: processor.settingPackage.totalDuration)
        exportSession.outputURL = URL.init(fileURLWithPath: exportFilePath)
        exportSession.outputFileType = .mp4
        
        exportSession.exportAsynchronously { [weak self] in
            guard let session = self?.exportSession else {
                return
            }
            switch session.status {
            case .unknown:
                break
            case .waiting:
                break
            case .exporting:
                break
            case .completed:
                self?.finish(errorMessage: nil, errorType: nil)
            case .failed:
                var errorMsg = "导出失败"
                if let error = session.error {
                    errorMsg = error.localizedDescription
                }
                self?.finish(errorMessage: errorMsg, errorType: .sessionError)
            case .cancelled:
                self?.finish(errorMessage: "已取消", errorType: self?.triggerError)
            @unknown default:
                print("default")
            }
        }
    }
}

//MARK:- Event
extension LHVideoCompositionExporter {
    @objc
    private func timerEvent() {
        delegate?.exporterProgress(progress: Double(exportSession.progress))
    }
}

//MARK:- Notification Event
extension LHVideoCompositionExporter {
    @objc
    private func enterBackgroundNotificationEvent() {
        if exportSession.status == .exporting {
            triggerError = .enterBackgroundCancel
            exportSession.cancelExport()
        }
    }
}
