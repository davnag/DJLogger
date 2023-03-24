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

/// Creates a DJLLogHandler that will write log to the file named  as `fileName`.
///
/// This example creates two instances of `DJLFileHandler`,
/// one with default file extension and the other with a value
/// you specify in  as `fileExtension`.
///
///     let fileHandler = DJLFileHandler("Log")
///     let fileHandler = DJLFileHandler("Log", fileExtension: "log")
///
public class DJLFileHandler {
    
    private let fileName: String
    private let fileExtension: String
    
    /// Creates a DJLLogHandler that will write log to the file named  as `fileName`.
    ///
    /// This example creates two instances of `DJLFileHandler`,
    /// one with default file extension and the other with a value
    /// you specify in  as `fileExtension`.
    ///
    ///     let fileHandler = DJLFileHandler("Log")
    ///     let fileHandler = DJLFileHandler("Log", fileExtension: "log")
    ///
    /// - Parameter fileName: File name without file extension.
    /// - Parameter fileExtension: File extension without `.`.
    ///
    /// - Returns: A `DJLFileHandler` to add to a `DJLLogger`.
    public init(_ fileName: String, fileExtension: String = "log") {
        
        self.fileName = fileName
        self.fileExtension = fileExtension
        
    }
}

// MARK: - DJLLogHandler

extension DJLFileHandler: DJLLogHandler {

    public func log(label: String,
                    level: DJLLogger.Level,
                    message: String,
                    file: String,
                    function: String,
                    line: UInt) {
        
        let date = DJLLoggerConfiguration.dateFormatter.string(from: Date())
        
        var log = ""
        log += "\(label)"
        log += ";\(date)"
        log += ";\(level.name)"
        log += ";\(file) (\(line))"
        log += ";\(function)"
        log += ";\(message)"
        
        appendLogToFile(text: log)
    }
}

// MARK: - Private

extension DJLFileHandler {
    
    private func appendLogToFile(text: String) {
        
        guard let data = ("\n" + text).data(using: .utf8) else {
            return
        }
        
        guard let dir = DJLFileHandlerConfiguration.path() else {
            return
        }
        
        let fileURL = dir.appendingPathComponent(fileName).appendingPathExtension(fileExtension)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            
            do {
                try text.write(to: fileURL, atomically: true, encoding: .utf8)
            } catch {
                print("Error writing to file \(error)")
            }
            
            return
        }
        
        do {
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
            fileHandle.closeFile()
        } catch {
            print("Error appending to file \(error)")
        }
    }
}
