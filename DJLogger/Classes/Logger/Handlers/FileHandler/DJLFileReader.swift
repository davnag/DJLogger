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

// MARK: - Read Log

struct DJLFileReader {
  
    static let queue = DispatchQueue(label: "DJLFileReader.readLogsFiles")
    
    static func readLogsFiles(completion: @escaping ([DJLFileLog]) -> Void) {
        
        var logFiles = [DJLFileLog]()

        guard let path = DJLFileHandlerConfiguration.path() else {
            completion(logFiles)
            return
        }

        queue.async {
            do {
                
                let fileURLs = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
                
                for fileURL in fileURLs {
                    
                    if let fileContent = try? String(contentsOf: fileURL, encoding: .utf8) {
    
                        let logs = fileContent
                            .components(separatedBy: CharacterSet.newlines)
                            .enumerated()
                            .map { (index: $0.offset, content: $0.element.components(separatedBy: ";")) }
                            .compactMap {  DJLFileLog(fileURL: fileURL, index: $0.index, content: $0.content) }
                        
                        logFiles += logs
                    }
                }
            } catch {
                print(error)
            }
            
            completion(logFiles)
        }
    }
    
    static func removeAllLogFiles(completion: @escaping () -> Void) {
        
        queue.async {
            
            guard let path = DJLFileHandlerConfiguration.path() else {
                completion()
                return
            }
            
            do {
                
                let fileURLs = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
                
                for fileURL in fileURLs {
                    do {
                        try FileManager.default.removeItem(at: fileURL)
                    } catch {
                        print(error)
                    }
                }
                
            } catch {
                print(error.localizedDescription)
            }
            
            completion()
        }
    }
}
