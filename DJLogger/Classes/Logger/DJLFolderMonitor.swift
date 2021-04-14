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

import Combine
import Foundation

public final class DJLFolderMonitor {

    // MARK: Private
    
    /// A file descriptor for the monitored directory.
    private var monitoredFolderFileDescriptor: CInt = -1

    private let folderMonitorQueue = DispatchQueue(label: "DJLFolderMonitor.Queue", attributes: .concurrent)

    private var folderMonitorSource: DispatchSourceFileSystemObject?

    private let url: Foundation.URL
    
    // MARK: Public
    
    public var folderDidChangeSubject = PassthroughSubject<Void, Never>()

    public init(url: Foundation.URL) {
        self.url = url
    }
    
    deinit {
        stopMonitoring()
    }
}

extension DJLFolderMonitor {

    func startMonitoring() {
        
        guard
            folderMonitorSource == nil,
            monitoredFolderFileDescriptor == -1
        else {
            return
        }

        monitoredFolderFileDescriptor = open(url.path, O_EVTONLY)
        
        folderMonitorSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: monitoredFolderFileDescriptor, eventMask: .extend, queue: folderMonitorQueue)
        
        folderMonitorSource?.setEventHandler { [weak self] in
            self?.folderDidChangeSubject.send(())
        }
        
        folderMonitorSource?.setCancelHandler { [weak self] in
        
            guard
                let self = self
            else {
                return
            }
            
            close(self.monitoredFolderFileDescriptor)
            self.monitoredFolderFileDescriptor = -1
            self.folderMonitorSource = nil
        }

        folderMonitorSource?.resume()
    }
    
    func stopMonitoring() {
        folderMonitorSource?.cancel()
    }
}
