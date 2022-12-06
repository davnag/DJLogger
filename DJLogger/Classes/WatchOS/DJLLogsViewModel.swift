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

final class DJLLogsViewModel: ObservableObject {
    
    struct DJLLogSection: Identifiable {
        
        var id: Date {
            return date
        }
        
        let date: Date
        let items: [DJLFileLog]
    }
    
    private var isRequestingLogs: Bool = false
    private var logsLoadTime: Int = 0
    private var refreshLogsTimer: Timer?
    private var refreshLogsStatusTimer: Timer?
    
    private var settings = DJLLogFilterSettings()
    
    private var logs: [DJLFileLog] = []
    
    @Published
    var sections: [DJLLogSection] = []
    
    init() {
        
    }
    
    deinit {
        stopRefreshTimer()
    }
    
    func startRefreshTimer() {
        refreshLogsTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.refreshLogs()
        }
    }
    
    func stopRefreshTimer() {
        self.logsLoadTime = 0
        refreshLogsTimer?.invalidate()
    }
    
    func clearLogs() {
        
        stopRefreshTimer()
        
        DJLFileReader.removeAllLogFiles { [weak self] in
            
            DispatchQueue.main.async { [weak self] in
                
                self?.sections.removeAll()
                
                self?.refreshLogs()
                //self.refreshLogUsage()
                self?.startRefreshTimer()
            }
        }
    }
    
    func refreshLogs() {
        
        guard
            settings.isPaused == false
        else {
            self.logsLoadTime = 0
            return
        }
        
        guard
            isRequestingLogs == false
        else {
            return
        }
        
        isRequestingLogs = true
        
        let startDate = Date()
        
        DJLFileReader.readLogsFiles { [weak self] logs in
            
            guard let self = self else {
                 return
            }
            
            let endDate = Date()
            let diffComponents = Calendar.current.dateComponents([.minute, .second], from: startDate, to: endDate)
            self.logsLoadTime = diffComponents.second ?? 0
            
            DispatchQueue.main.async { [weak self] in
                self?.isRequestingLogs = false
                
                guard self?.settings.isPaused == false else {
                    return
                }
                
                self?.logs = logs
                //self?.updateSettingsLables(with: logs)
                self?.filter(logs)
            }
        }
    }
    
    private func filter(_ logs: [DJLFileLog]) {
        
        var filtred = logs.filter({ settings.levels.contains($0.level) })
        
        if settings.selectedLabels.isEmpty == false {
            filtred = filtred.filter({ settings.selectedLabels.contains($0.label) })
        }
        
        filtred = filtred.sorted(by: { $0.date.compare($1.date) == .orderedDescending })

        updateSections(items: filtred)
    }
    
    private func updateSections(items: [DJLFileLog]) {
        
        let grouped = items.sliced(by: [.year, .month, .day], for: \.date)
        
        let sections = grouped.compactMap({ DJLLogSection(date: $0.key, items: $0.value) })
        
        self.sections = sections.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
    }
}
