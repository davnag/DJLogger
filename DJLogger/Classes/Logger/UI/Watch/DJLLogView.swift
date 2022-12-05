//
//  DJLLogView.swift
//  DJLogger
//
//  Created by David Jonsén on 2022-12-05.
//

#if os(watchOS)
    
private extension DJLLogger.Level {
    
    var color: Color {
        switch self {
        case .trace, .debug:
            return .green
        case .warning:
            return .yellow
        case .error, .critical:
            return .red
        }
    }
}

import SwiftUI

final class DJLLogViewModel: ObservableObject {
    
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

public struct DJLLogView: View {
    
    @Environment(\.dismiss)
    private var dismiss
    
    @State
    private var isPresentingRemoveLogsDialog: Bool = false
    
    @StateObject
    private var viewModel: DJLLogViewModel
    
    public init() {
        _viewModel = StateObject(wrappedValue: DJLLogViewModel())
    }
    
    public var body: some View {
        
        NavigationStack {
            
            ScrollView {

                LazyVStack {
                    
                    ForEach(viewModel.sections) { section in
                        
                        Section {
                            
                            ForEach(section.items) { log in
                                LogView(log: log)
                            }
                            
                        } header: {
                            
                            Text(section.date, style: .date)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 10)
                        }
                    }
                }
            }
            .navigationTitle("Logs")
            .toolbar {
                
                ToolbarItemGroup(placement: .cancellationAction) {
                    
                    Button("Done", role: .cancel) {
                        
                        dismiss()
                    }
                }
                
                ToolbarItemGroup(placement: .confirmationAction) {
                    
                    HStack {
                        
                        Button(role: .destructive) {
                            isPresentingRemoveLogsDialog = true
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .confirmationDialog("Clear Logs", isPresented: $isPresentingRemoveLogsDialog) {
                            
                            Button("Yes", role: .destructive) {
                                self.viewModel.clearLogs()
                            }
                            
                        } message: {
                            Text("Do you want to Clear All Logs?")
                        }

                        Button {
                            
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        }
                    }
                }
            }
            .onAppear {
                viewModel.refreshLogs()
                viewModel.startRefreshTimer()
            }
            .onDisappear {
                viewModel.stopRefreshTimer()
            }
        }
    }
}

struct LogView: View {
    
    let log: DJLFileLog
    
    var body: some View {
        
        VStack {
            
            VStack(alignment: .leading, spacing: 2) {
                
                HStack {
                    
                    Text(log.date, style: .time)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(log.level.name)
                        .foregroundColor(.white)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background {
                            log.level.color
                                .mask {
                                    RoundedRectangle(cornerRadius: 4)
                                }
                        }
                }
                
                Text(log.message)
                    .font(.body)
                    .padding(.vertical, 2)
                
                
                
                Text(log.meta)
                    .font(.system(size: 9))
                    .italic()
                    .foregroundColor(.secondary)
                
                Text(log.label)
                    .font(.footnote)
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .background {
            
            Color(uiColor: UIColor(red: 16/255.0, green: 16/255.0, blue: 16/255.0, alpha: 1))
                .mask {
                    RoundedRectangle(cornerRadius: 4)
                }
        }
        .padding(.vertical, 2)
    }
}

struct DJLLogView_Previews: PreviewProvider {
    static var previews: some View {
        DJLLogView()
    }
}

#endif
