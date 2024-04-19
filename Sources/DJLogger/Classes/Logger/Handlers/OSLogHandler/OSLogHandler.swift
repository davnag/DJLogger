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

import OSLog
import Foundation

@available(iOS 14.0, *)
public class OSLogHandler {
    
    fileprivate final class DJOSLogger: Identifiable {
        
        var id: String {
            category
        }
        
        let category: String
        
        let logger: Logger
        
        init(category: String) {
            self.category = category
            //swiftlint:disable force_unwrapping
            self.logger = Logger(
                subsystem: Bundle.main.bundleIdentifier!,
                category: category
            )
            //swiftlint:enable force_unwrapping
        }
    }

    fileprivate static var loggers = [DJOSLogger]()
    
    /// Creates a Log Handler that prints message to OSLog
    public init() { }
}

// MARK: - DJLLogHandler

@available(iOS 14.0, *)
extension OSLogHandler: DJLLogHandler {
    
    public func log(label: String,
                    level: DJLLogger.Level,
                    message: String,
                    file: String,
                    function: String,
                    line: UInt) {
        
        let logger: Logger
        
        if let existingLogger = Self.loggers.first(where: { $0.category == label }) {
            logger = existingLogger.logger
        } else {
            
            let newLogger = DJOSLogger(category: label)
            
            Self.loggers.append(newLogger)
            
            logger = newLogger.logger
        }

        var log = ""
        log += "\(file) (\(line))"
        log += " -> \(function)"
        log += " > \(message)\n"
        
        switch level {
        case .trace:
            logger.trace("\(log)")
        case .debug:
            logger.debug("\(log)")
        case .warning:
            logger.warning("\(log)")
        case .error:
            logger.error("\(log)")
        case .critical:
            logger.critical("\(log)")
        }
    }
}
