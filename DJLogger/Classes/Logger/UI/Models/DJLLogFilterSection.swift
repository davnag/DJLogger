//
//  DJLLogFilterSection.swift
//  Pods
//
//  Created by David Jonsén on 2022-12-06.
//

import Foundation

struct DJLLogFilterSection: Identifiable {
    
    var id: UUID = .init()
    
    let title: String
    
    let items: [DJLLogFilterRow]
}

struct DJLLogFilterRow: Identifiable {
    
    enum RowType {
        case checkmark
    }
    
    var id: UUID = .init()
    
    let title: String
    let group: String
    
    let type: RowType
}
