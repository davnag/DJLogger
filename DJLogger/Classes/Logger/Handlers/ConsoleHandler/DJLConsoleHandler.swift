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

public class DJLConsoleHandler {
    
    /// Creates a Log Handler that prints message to console if DEBUG
    public init() { }
}

// MARK: - DJLLogHandler

extension DJLConsoleHandler: DJLLogHandler {
  
    public func log(label: String,
                    level: DJLLogger.Level,
                    message: String,
                    file: String,
                    function: String,
                    line: UInt) {
        
        let date = DJLLoggerConfiguration.dateFormatter.string(from: Date())
        
        var log = ""
        log += "\(label) | "
        log += "\(date) | \(level.name)"
        log += " | \(file) (\(line))"
        log += " -> \(function)"
        log += " > \(message)\n"
        
        #if DEBUG
        print(log)
        #endif
    }
}
