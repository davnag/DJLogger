//
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

public struct DJLLogger {
    
    public enum Level: Int, CaseIterable {
        case trace = 0
        case debug = 1
        case warning = 2
        case error = 3
        case critical = 4
    }
    
    public let label: String
    public let logLevel: Level
    
    private var handlers: [DJLLogHandler]
    
    public init(_ label: String, logLevel: Level = .trace, _ handlers: [DJLLogHandler]) {
        self.label = label
        self.logLevel = logLevel
        self.handlers = handlers
    }
}

// MARK: - Public

extension DJLLogger {
    
    public func log(level: DJLLogger.Level,
                    _ message: @autoclosure () -> String,
                    file: String = #fileID, function: String = #function, line: UInt = #line) {
        
        if DJLLoggerConfiguration.logEnabled, self.logLevel <= level {
            self.handlers.forEach {
                $0.log(label: label, level: level, message: message(), file: file, function: function, line: line)
            }
        }
    }
    
    public func trace(_ message: @autoclosure () -> String,
                      file: String = #fileID, function: String = #function, line: UInt = #line) {
        self.log(level: .trace, message(), file: file, function: function, line: line)
    }
    
    public func debug(_ message: @autoclosure () -> String,
                      file: String = #fileID, function: String = #function, line: UInt = #line) {
        self.log(level: .debug, message(), file: file, function: function, line: line)
    }
    
    public func warning(_ message: @autoclosure () -> String,
                        file: String = #fileID, function: String = #function, line: UInt = #line) {
        self.log(level: .warning, message(), file: file, function: function, line: line)
    }
    
    public func error(_ message: @autoclosure () -> String,
                      file: String = #fileID, function: String = #function, line: UInt = #line) {
        self.log(level: .error, message(), file: file, function: function, line: line)
    }
    
    public func critical(_ message: @autoclosure () -> String,
                         file: String = #fileID, function: String = #function, line: UInt = #line) {
        self.log(level: .critical, message(), file: file, function: function, line: line)
    }
}
