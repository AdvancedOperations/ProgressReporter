//
//  Progress.swift
//  HvSockets
//
//  Created by Oleg Dreyman on 09.06.16.
//  Copyright © 2016 Heeveear. All rights reserved.
//

import Foundation

protocol ProgressReporting {
    
    func getProgressReporter() -> ProgressReporter
    
}

extension ProgressReporting where Self: NSProgressReporting {
    
    func getProgressReporter() -> ProgressReporter {
        return ProgressReporter(progress: progress)
    }
    
}
