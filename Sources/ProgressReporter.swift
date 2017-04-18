//
//  ProgressCustomer.swift
//  HvSockets
//
//  Created by Oleg Dreyman on 09.06.16.
//  Copyright © 2016 Heeveear. All rights reserved.
//

import Foundation

private var progressReporterObservationContext = 0

public final class ProgressReporter: NSObject {
    
    fileprivate let progress: Progress
    
    public init(progress: Progress) {
        self.progress = progress
        super.init()
        registerForKVO()
    }
    
    deinit {
        for key in ProgressReporter.overalProgressObservedKeys {
            progress.removeObserver(self, forKeyPath: key.rawValue, context: &progressReporterObservationContext)
        }
    }
    
    open weak var delegate: ProgressReporterDelegate?
    
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
            progress.addObserver(self, forKeyPath: key.rawValue, options: [.new], context: &progressReporterObservationContext)
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &progressReporterObservationContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
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
            if progress.isCancelled {
                delegate?.progressReporterDidCancel(self)
            }
        case .paused:
            if progress.isPaused {
                delegate?.progressReporterDidPause(self)
            } else {
                delegate?.progressReporterDidResume(self)
            }
        }
    }
    
}

public protocol ProgressReporterDelegate: class {
    
    func progressReporter(_ progressReporter: ProgressReporter, didChangeFractionCompleted fractionCompleted: Double)
    func progressReporter(_ progressReporter: ProgressReporter, didChangeCompletedUnitCount completedUnitCount: Int64)
    func progressReporter(_ progressReporter: ProgressReporter, didChangeTotalUnitCount totalUnitCount: Int64)
    func progressReporterDidCancel(_ progressReporter: ProgressReporter)
    func progressReporterDidPause(_ progressReporter: ProgressReporter)
    func progressReporterDidResume(_ progressReporter: ProgressReporter)
    
}

extension ProgressReporterDelegate {
    
    public func progressReporter(_ progressReporter: ProgressReporter, didChangeFractionCompleted fractionCompleted: Double) { }
    public func progressReporter(_ progressReporter: ProgressReporter, didChangeCompletedUnitCount completedUnitCount: Int64) { }
    public func progressReporter(_ progressReporter: ProgressReporter, didChangeTotalUnitCount totalUnitCount: Int64) { }
    public func progressReporterDidCancel(_ progressReporter: ProgressReporter) { }
    public func progressReporterDidPause(_ progressReporter: ProgressReporter) { }
    public func progressReporterDidResume(_ progressReporter: ProgressReporter) { }

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
    
    public var isCancellable: Bool {
        return progress.isCancellable
    }
    
    public var isCancelled: Bool {
        return progress.isCancelled
    }
    
    public var isPausable: Bool {
        return progress.isPausable
    }
    
    public var isPaused: Bool {
        return progress.isPaused
    }
    
    public var kind: ProgressKind? {
        return progress.kind
    }
    
    public var isIndeterminate: Bool {
        return progress.isIndeterminate
    }
    
    public var userInfo: [ProgressUserInfoKey: Any] {
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
