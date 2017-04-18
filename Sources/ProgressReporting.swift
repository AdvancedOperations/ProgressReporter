//
//  Progress.swift
//  HvSockets
//
//  Created by Oleg Dreyman on 09.06.16.
//  Copyright © 2016 Heeveear. All rights reserved.
//

import Foundation

public protocol ProgressReporting {
    
    func makeProgressReporter() -> ProgressReporter
    
}

extension ProgressReporting where Self : Foundation.ProgressReporting {
    
    public func makeProgressReporter() -> ProgressReporter {
        return ProgressReporter(progress: progress)
    }
    
}
