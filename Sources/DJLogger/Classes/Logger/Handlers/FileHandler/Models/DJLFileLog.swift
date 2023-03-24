/*
 The MIT License (MIT)

 Copyright (c) 2021 David Jonsén

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import Foundation

public struct DJLFileLog: Identifiable {
    
    public var id: String {
        return "\(fileName)->\(index)"
    }
    
    public let index: Int
    
    public let fileURL: URL
    public var fileName: String {
        return fileURL.lastPathComponent
    }
    
    public let label: String
    public let date: Date
    public let level: DJLLogger.Level
    public let file: String
    public let function: String
    public let message: String

    init?(fileURL: URL, index: Int, content: [String]) {
        
        self.index = index
        self.fileURL = fileURL
        
        self.label = content[0]
        
        let dateString = content[1]
        if let date = DJLLoggerConfiguration.dateFormatter.date(from: dateString) {
            self.date = date
        } else {
            return nil
        }
        
        if let level = DJLLogger.Level.from(content[2]) {
            self.level = level
        } else {
            return nil
        }
        
        self.file = content[3]
        self.function = content[4]
        self.message = content[5]
    }
}

extension DJLFileLog {
    
    public func logText() -> String {

        var log = ""
        log += "\(date)"
        log += " | \(level.name)"
        log += " | \(label)"
        log += " | \(file)"
        log += " -> \(function)"
        log += " > \(message)\n"
        
        return log
    }
}

extension DJLFileLog: CustomStringConvertible {
    
    public var description: String {

        var log = ""
        log += "\(date)"
        log += " | \(level.name)"
        log += " | \(label)"
        log += " | \(file)"
        log += " -> \(function)"
        log += " > \(message)\n"
        
        log += "\nFile: \(fileURL)"
        
        return log
    }
}
