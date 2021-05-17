//
//  DJLLogFilterSettings.swift
//  DJLogger
//
//  Created by David Jonsén on 2021-05-17.
//

import Foundation

public final class DJLLogFilterSettings {
    
    public var labels: [String] = []
    public var selectedLabels: [String] = []
    public var levels: [DJLLogger.Level] = DJLLogger.Level.allCases
    
    public var isPaused: Bool = false
    
    var active: Bool {
        
        if selectedLabels.isEmpty == false {
            return true
        }
        
        return levels.count != DJLLogger.Level.allCases.count
    }
}
