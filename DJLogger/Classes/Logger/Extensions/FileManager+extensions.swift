//
//  FileManager+extensions.swift
//  DJLogger
//
//  Created by David Jonsén on 2021-05-17.
//

import Foundation

extension FileManager {
    
    func sizeOfFile(atPath path: String) -> Int64? {
        
        guard let attrs = try? attributesOfItem(atPath: path) else {
            return nil
        }

        return attrs[.size] as? Int64
    }
}
