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
import UIKit

public final class DJLLogFilterSettings {
    
    public var labels: [String] = []
    public var selectedLabels: [String] = []
    public var levels: [DJLLogger.Level] = DJLLogger.Level.allCases
    
    var active: Bool {
        if selectedLabels.isEmpty == false {
            return true
        }
        return levels.count != DJLLogger.Level.allCases.count
    }
}



public final class DJLLogViewController: UITableViewController {
    
    private struct DJLLogSection {
        let date: Date
        let items: [DJLFileLog]
    }

    private var logs: [DJLFileLog] = []
    
    private var sections: [DJLLogSection] = []
    private var settings = DJLLogFilterSettings()
    
    private var refreshLogsTimer: Timer?
    
    private var folderMonitor: DJLFolderMonitor?
    private var folderChangedCancellable: AnyCancellable?
    
    public init() {
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        setupViewController()
        
        refreshLogs()
        startRefreshTimer()
        setupBarButtonItems()
        
//        if let path = DJLFileHandler.path() {
//            self.folderMonitor = DJLFolderMonitor(url: path)
//            folderChangedCancellable = folderMonitor?.folderDidChangeSubject
//                .receive(on: DispatchQueue.main)
//                .sink { _ in
//                    print("Refresh Logs")
//                }
//
//            folderMonitor?.startMonitoring()
//        }
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        refreshLogsTimer?.invalidate()
    }
}

// MARK: - Setup

extension DJLLogViewController {

    private func setupViewController() {

        title = "Logs"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.allowsSelection = false
        tableView.register(DJLLogCell.self, forCellReuseIdentifier: "DJLLogCell")
    }
    
    private func setupBarButtonItems() {
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "xmark.circle.fill"), style: .plain, target: self, action: #selector(closeButtonAction))
        ]
        
        if settings.active {
            navigationItem.leftBarButtonItems = [
                UIBarButtonItem(image: UIImage(systemName: "switch.2"), style: .plain, target: self, action: #selector(menuButtonAction)),
                UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle.fill"), style: .plain, target: self, action: #selector(filterButtonAction))
            ]
        } else {
            navigationItem.leftBarButtonItems = [
                UIBarButtonItem(image: UIImage(systemName: "switch.2"), style: .plain, target: self, action: #selector(menuButtonAction)),
                UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"), style: .plain, target: self, action: #selector(filterButtonAction))
            ]
        }
    }
}

// MARK: - Private

extension DJLLogViewController {

    private func refreshLogs() {
        
        DJLFileReader.readLogsFiles { logs in
            DispatchQueue.main.async { [weak self] in
                self?.logs = logs
                self?.updateSettingsLables(with: logs)
                self?.filter(logs)
            }
        }
    }
    
    private func updateSettingsLables(with logs: [DJLFileLog]) {
        
        let uniqueLabels = Set(logs.map({ $0.label })).sorted(by: { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending })
        settings.labels = uniqueLabels
        
        let selectedLabels = settings.selectedLabels
        for selectedLabel in selectedLabels {
            if uniqueLabels.contains(selectedLabel) == false {
                settings.selectedLabels.removeAll(where: { $0 == selectedLabel })
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
        self.sections = grouped.compactMap({ DJLLogSection(date: $0.key, items: $0.value) })
        self.sections.sort(by: { $0.date.compare($1.date) == .orderedDescending })
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func startRefreshTimer() {
        refreshLogsTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in self.refreshLogs() }
    }
    
    private func stopRefreshTimer() {
        refreshLogsTimer?.invalidate()
    }
}

// MARK: - Actions

extension DJLLogViewController {
    
    @objc
    private func filterButtonAction() {
        
        stopRefreshTimer()
        
        let controller = DJLLogFilterViewController(settings: settings)
        let navController = UINavigationController(rootViewController: controller)
        navController.presentationController?.delegate = self
        present(navController, animated: true)
    }
    
    @objc
    private func menuButtonAction() {

        stopRefreshTimer()
        
        let controller = UIAlertController(title: "Logs", message: nil, preferredStyle: .actionSheet)
        
        controller.addAction(UIAlertAction(title: "Clear All Logs", style: .destructive) { _ in
            
            DJLFileReader.removeAllLogFiles {
                
                DispatchQueue.main.async {
                    
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    
                    self.sections.removeAll()
                    self.tableView.reloadData()
                    
                    self.startRefreshTimer()
                }
            }
        })
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.startRefreshTimer()
        })
        
        present(controller, animated: true)
    }
    
    @objc
    private func closeButtonAction() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension DJLLogViewController {
    
    override public func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].items.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DJLLogCell", for: indexPath) as? DJLLogCell else {
            fatalError()
        }
        
        let log = sections[indexPath.section].items[indexPath.row]
        cell.log = log
        
        return cell
    }
    
    override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        let now = Date()
        let date = sections[section].date
        let components = Calendar.current.dateComponents([.day],
                                                         from: Calendar.current.startOfDay(for: date),
                                                         to: Calendar.current.startOfDay(for: now))
        
        if components.day == 0 {
            return "Today"
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: now)
    }
    
    // MARK: ContextMenu
    
    public override func tableView(_ tableView: UITableView, willDisplayContextMenu configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        
        stopRefreshTimer()
    }
    
    override public func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {

        let item = sections[indexPath.section].items[indexPath.row]
      
        let actionProvider: UIContextMenuActionProvider = { _ in
            let editMenu = UIMenu(title: "Edit...", children: [
                UIAction(title: "Copy") { _ in
                    let description = item.description
                    UIPasteboard.general.string = description
                }
            ])
            return UIMenu(title: "Log", children: [
                UIAction(title: "Share") { [weak self] _ in
                    let description = item.description
                    let controller = UIActivityViewController(activityItems: [description], applicationActivities: nil)
                    self?.present(controller, animated: true)
                },
                editMenu
            ])
        }

        return UIContextMenuConfiguration(identifier: "\(item.id)" as NSCopying, previewProvider: nil, actionProvider: actionProvider)
    }
    
    public override func tableView(_ tableView: UITableView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        
        startRefreshTimer()
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension DJLLogViewController: UIAdaptivePresentationControllerDelegate {
    
    public func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        
        setupBarButtonItems()
        startRefreshTimer()
    }
}
