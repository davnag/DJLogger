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


public struct DJLFileReader {
    
    public enum DJLFileReaderError: Error {
        case noPath
    }
  
    private static let queue = DispatchQueue(label: "DJLFileReader.readLogsFiles")
    
    public static func logFilesURLs() throws -> [URL] {
        
        guard let path = DJLFileHandlerConfiguration.path() else {
            throw DJLFileReaderError.noPath
        }
        
        return try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
    }

    public static func readLogsFiles(completion: @escaping ([DJLFileLog]) -> Void) {
        
        var logFiles = [DJLFileLog]()

        queue.async {
            
            do {

                for fileURL in try DJLFileReader.logFilesURLs() {
                    
                    if let fileContent = try? String(contentsOf: fileURL, encoding: .utf8) {
    
                        let logs = fileContent
                            .components(separatedBy: CharacterSet.newlines)
                            .enumerated()
                            .map { (index: $0.offset, content: $0.element.components(separatedBy: ";")) }
                            .compactMap {  DJLFileLog(fileURL: fileURL, index: $0.index, content: $0.content) }
                        
                        logFiles += logs.suffix(500)
                    }
                }
            } catch {
                print(error)
            }
            
            completion(logFiles)
        }
    }
    
    public static func removeAllLogFiles(completion: @escaping () -> Void) {
        
        queue.async {
            
            do {
                
                for fileURL in try DJLFileReader.logFilesURLs() {
                    do {
                        try FileManager.default.removeItem(at: fileURL)
                    } catch {
                        print(error)
                    }
                }
                
            } catch {
                print(error)
            }
            
            completion()
        }
    }
    
    public static func logFileSize() -> String? {
        
        var byteCountFormatter: ByteCountFormatter {
            let byteCountFormatter = ByteCountFormatter()
            byteCountFormatter.allowedUnits = [.useMB]
            byteCountFormatter.countStyle = .file
            return byteCountFormatter
        }
        
        var totalFileSize: Int64 = 0

        do {
            
            let fileURLs = try DJLFileReader.logFilesURLs()
            totalFileSize = fileURLs.reduce(0) { $0 + (FileManager.default.sizeOfFile(atPath: $1.path) ?? 0) }

        } catch {
            print(error)
        }
        
        return byteCountFormatter.string(fromByteCount: totalFileSize)
    }
}
