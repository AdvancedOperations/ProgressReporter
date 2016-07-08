//
//  ProgressCustomer.swift
//  HvSockets
//
//  Created by Oleg Dreyman on 09.06.16.
//  Copyright © 2016 Heeveear. All rights reserved.
//

import Foundation

private var progressReporterObservationContext = 0

public class ProgressReporter: NSObject {
    
    private let progress: NSProgress
    
    public init(progress: NSProgress) {
        self.progress = progress
        super.init()
        registerForKVO()
    }
    
    deinit {
        for key in ProgressReporter.overalProgressObservedKeys {
            progress.removeObserver(self, forKeyPath: key.rawValue, context: &progressReporterObservationContext)
        }
    }
    
    public weak var delegate: ProgressReporterDelegate?
    
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
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
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

public protocol ProgressReporterDelegate: class {
    
    func progressReporter(progressReporter: ProgressReporter, didChangeFractionCompleted fractionCompleted: Double)
    func progressReporter(progressReporter: ProgressReporter, didChangeCompletedUnitCount completedUnitCount: Int64)
    func progressReporter(progressReporter: ProgressReporter, didChangeTotalUnitCount totalUnitCount: Int64)
    func progressReporterDidCancel(progressReporter: ProgressReporter)
    func progressReporterDidPause(progressReporter: ProgressReporter)
    func progressReporterDidResume(progressReporter: ProgressReporter)
    
}

extension ProgressReporterDelegate {
    
    public func progressReporter(progressReporter: ProgressReporter, didChangeFractionCompleted fractionCompleted: Double) { }
    public func progressReporter(progressReporter: ProgressReporter, didChangeCompletedUnitCount completedUnitCount: Int64) { }
    public func progressReporter(progressReporter: ProgressReporter, didChangeTotalUnitCount totalUnitCount: Int64) { }
    public func progressReporterDidCancel(progressReporter: ProgressReporter) { }
    public func progressReporterDidPause(progressReporter: ProgressReporter) { }
    public func progressReporterDidResume(progressReporter: ProgressReporter) { }

}

extension ProgressReporter {
    
    public var totalUnitCount: Int64 {
        return progress.totalUnitCount
    }
    
    public var completedUnitCount: Int64 {
        return progress.completedUnitCount
    }
    
    public var fractionCompleted: Double {
        return progress.fractionCompleted
    }
    
    public var localizedDescription: String {
        return progress.localizedDescription
    }
    
    public var localizedAdditionalDescription: String {
        return progress.localizedAdditionalDescription
    }
    
    public var cancellable: Bool {
        return progress.cancellable
    }
    
    public var cancelled: Bool {
        return progress.cancelled
    }
    
    public var pausable: Bool {
        return progress.pausable
    }
    
    public var paused: Bool {
        return progress.paused
    }
    
    public var kind: String? {
        return progress.kind
    }
    
    public var indeterminate: Bool {
        return progress.indeterminate
    }
    
    public var userInfo: [NSObject: AnyObject] {
        return progress.userInfo
    }
    
    public func cancel() {
        progress.cancel()
    }
    
    public func pause() {
        progress.pause()
    }
    
    @available(OSXApplicationExtension 10.11, *)
    public func resume() {
        progress.resume()
    }
    
}
