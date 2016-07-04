//
//  ProgressCustomer.swift
//  HvSockets
//
//  Created by Oleg Dreyman on 09.06.16.
//  Copyright © 2016 Heeveear. All rights reserved.
//

import Foundation

private var progressReporterObservationContext = 0

class ProgressReporter: NSObject {
    
    private let progress: NSProgress
    
    init(progress: NSProgress) {
        self.progress = progress
        super.init()
        registerForKVO()
    }
    
    deinit {
        for key in ProgressReporter.overalProgressObservedKeys {
            progress.removeObserver(self, forKeyPath: key.rawValue, context: &progressReporterObservationContext)
        }
    }
    
    weak var delegate: ProgressReporterDelegate?
    
    private enum ProgressKey: String {
        case fractionCompleted
        case completedUnitCount
        case totalUnitCount
        case cancelled
        case paused
    }
    
    static private let overalProgressObservedKeys: [ProgressKey] = [
        .fractionCompleted,
        .completedUnitCount,
        .totalUnitCount,
        .cancelled,
        .paused,
    ]
    
    private func registerForKVO() {
        for key in ProgressReporter.overalProgressObservedKeys {
            progress.addObserver(self, forKeyPath: key.rawValue, options: [.New], context: &progressReporterObservationContext)
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard context == &progressReporterObservationContext else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        guard let key = keyPath.flatMap({ ProgressKey(rawValue: $0) }) else {
            return
        }
        switch key {
        case .fractionCompleted:
            delegate?.progressReporter(self, didChangeFractionCompleted: progress.fractionCompleted)
        case .completedUnitCount:
            delegate?.progressReporter(self, didChangeCompletedUnitCount: progress.completedUnitCount)
        case .totalUnitCount:
            delegate?.progressReporter(self, didChangeTotalUnitCount: progress.totalUnitCount)
        case .cancelled:
            if progress.cancelled {
                delegate?.progressReporterDidCancel(self)
            }
        case .paused:
            if progress.paused {
                delegate?.progressReporterDidPause(self)
            } else {
                delegate?.progressReporterDidResume(self)
            }
        }
    }
    
}

protocol ProgressReporterDelegate: class {
    
    func progressReporter(progressReporter: ProgressReporter, didChangeFractionCompleted fractionCompleted: Double)
    func progressReporter(progressReporter: ProgressReporter, didChangeCompletedUnitCount completedUnitCount: Int64)
    func progressReporter(progressReporter: ProgressReporter, didChangeTotalUnitCount totalUnitCount: Int64)
    func progressReporterDidCancel(progressReporter: ProgressReporter)
    func progressReporterDidPause(progressReporter: ProgressReporter)
    func progressReporterDidResume(progressReporter: ProgressReporter)
    
}

extension ProgressReporterDelegate {
    
    func progressReporter(progressReporter: ProgressReporter, didChangeFractionCompleted fractionCompleted: Double) { }
    func progressReporter(progressReporter: ProgressReporter, didChangeCompletedUnitCount completedUnitCount: Int64) { }
    func progressReporter(progressReporter: ProgressReporter, didChangeTotalUnitCount totalUnitCount: Int64) { }
    func progressReporterDidCancel(progressReporter: ProgressReporter) { }
    func progressReporterDidPause(progressReporter: ProgressReporter) { }
    func progressReporterDidResume(progressReporter: ProgressReporter) { }

}

extension ProgressReporter {
    
    var totalUnitCount: Int64 {
        return progress.totalUnitCount
    }
    
    var completedUnitCount: Int64 {
        return progress.completedUnitCount
    }
    
    var fractionCompleted: Double {
        return progress.fractionCompleted
    }
    
    var localizedDescription: String {
        return progress.localizedDescription
    }
    
    var localizedAdditionalDescription: String {
        return progress.localizedAdditionalDescription
    }
    
    var cancellable: Bool {
        return progress.cancellable
    }
    
    var cancelled: Bool {
        return progress.cancelled
    }
    
    var pausable: Bool {
        return progress.pausable
    }
    
    var paused: Bool {
        return progress.paused
    }
    
    var kind: String? {
        return progress.kind
    }
    
    var indeterminate: Bool {
        return progress.indeterminate
    }
    
    var userInfo: [NSObject: AnyObject] {
        return progress.userInfo
    }
    
    func cancel() {
        progress.cancel()
    }
    
    func pause() {
        progress.pause()
    }
    
    @available(OSXApplicationExtension 10.11, *)
    func resume() {
        progress.resume()
    }
    
}
