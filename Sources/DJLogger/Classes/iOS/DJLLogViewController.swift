#if os(iOS)
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

import UIKit
import Combine

final class DJLLogViewHeaderView: UIView {
    
    public lazy var messageLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.adjustsFontForContentSizeCategory = true
        view.adjustsFontSizeToFitWidth = true
        view.textColor = .secondaryLabel
        view.numberOfLines = 0
        view.font = .preferredFont(forTextStyle: .caption1)
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    
    private func setupSubviews() {
        addSubview(messageLabel)
    }
    
    private func setupConstraints() {
        preservesSuperviewLayoutMargins = true
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 16),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ])
    }
}

public final class DJLLogViewController: UITableViewController {
    
    private struct DJLLogSection {
        let date: Date
        let items: [DJLFileLog]
    }
    
    private lazy var headerView: DJLLogViewHeaderView = {
        let view = DJLLogViewHeaderView()
        view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 26)
        return view
    }()

    private var logs: [DJLFileLog] = []
    
    private var sections: [DJLLogSection] = []
    private var settings = DJLLogFilterSettings()
    
    private var isRequestingLogs: Bool = false
    private var logsLoadTime: Int = 0
    private var refreshLogsTimer: Timer?
    private var refreshLogsStatusTimer: Timer?
    
    private var folderMonitor: DJLFolderMonitor?
    private var folderChangedCancellable: AnyCancellable?
    
    private var previewHandler: DJLPreviewHandler?
    
    public init() {
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        setupViewController()
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
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshLogs()
        refreshLogUsage()
        startRefreshTimer()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        refreshLogsTimer?.invalidate()
        refreshLogsStatusTimer?.invalidate()
    }
}

// MARK: - Setup

extension DJLLogViewController {

    private func setupViewController() {

        title = "Logs"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.tableHeaderView = headerView
        tableView.allowsSelection = false
        tableView.register(DJLLogCell.self, forCellReuseIdentifier: "DJLLogCell")
    }
    
    private func setupBarButtonItems() {
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "xmark.circle.fill"), style: .plain, target: self, action: #selector(closeButtonAction))
        ]
        
        navigationItem.leftBarButtonItems = [
            setupMenuBarButtonItem(),
            setupTrashBarButtonItem(),
            setupPlayPauseBarButtonItem(),
            setupFilterBarButtonItem()
        ]
    }
    
    private func setupMenuBarButtonItem() -> UIBarButtonItem {
        UIBarButtonItem(image: UIImage(systemName: "switch.2"), style: .plain, target: self, action: #selector(menuButtonAction))
    }
    
    private func setupTrashBarButtonItem() -> UIBarButtonItem {
        UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(trashButtonAction))
    }
    
    private func setupFilterBarButtonItem() -> UIBarButtonItem {
        if settings.active {
            return UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle.fill"), style: .plain, target: self, action: #selector(filterButtonAction))
        } else {
            return UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"), style: .plain, target: self, action: #selector(filterButtonAction))
        }
    }
    
    private func setupPlayPauseBarButtonItem() -> UIBarButtonItem {
        if settings.isPaused {
            return UIBarButtonItem(image: UIImage(systemName: "play.fill"), style: .plain, target: self, action: #selector(playPauseButtonAction))
        } else {
            return UIBarButtonItem(image: UIImage(systemName: "pause.fill"), style: .plain, target: self, action: #selector(playPauseButtonAction))
        }
    }
}

// MARK: - Private

extension DJLLogViewController {
    
    private func refreshLogUsage() {
        
        DispatchQueue.global().async {
            
            guard let size = DJLFileReader.logFileSize(), let logFilesURLs = try? DJLFileReader.logFilesURLs() else {
                return
            }
            
            var message = "Usage: \(size) • \(logFilesURLs.count) files"
            
            if self.logsLoadTime > 1 {
                message += " • \(self.logsLoadTime)s load time"
            }
            
            var height = 26
            
            if DJLLoggerConfiguration.logEnabled == false {
                message = "Logging Globaly Disabled\n\(message)"
                height = 42
            }
            
            DispatchQueue.main.async { [weak self] in
                
                self?.headerView.frame = CGRect(x: 0, y: 0, width: Int((self?.view.bounds.width) ?? 0), height: height)
                self?.headerView.messageLabel.text = message
            }
        }
    }

    private func refreshLogs() {
        
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
        
        DJLFileReader.readLogsFiles { logs in
            
            let endDate = Date()
            let diffComponents = Calendar.current.dateComponents([.minute, .second], from: startDate, to: endDate)
            self.logsLoadTime = diffComponents.second ?? 0
            
            DispatchQueue.main.async { [weak self] in
                self?.isRequestingLogs = false
                
                guard self?.settings.isPaused == false else {
                    return
                }
                
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
        refreshLogsTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.refreshLogs()
        }
        
        refreshLogsStatusTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.refreshLogUsage()
        }
    }
    
    private func stopRefreshTimer() {
        self.logsLoadTime = 0
        refreshLogsTimer?.invalidate()
        refreshLogsStatusTimer?.invalidate()
    }
}

// MARK: - Actions

extension DJLLogViewController {

    @objc
    private func menuButtonAction() {

        stopRefreshTimer()
        
        let controller = UIAlertController(title: "Logs", message: nil, preferredStyle: .actionSheet)
        
        controller.addAction(UIAlertAction(title: "View log files", style: .default) { [self] _ in
            
            guard let files = try? DJLFileReader.logFilesURLs() else {
                return
            }
            
            let items = files.compactMap({ DJLPreviewHandler.PreviewItem(title: $0.lastPathComponent, url: $0) })
            
            self.previewHandler = DJLPreviewHandler(items: items) {
                self.startRefreshTimer()
                self.previewHandler = nil
            }
            self.previewHandler?.present(parent: self)
        })

        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.startRefreshTimer()
        })
        
        present(controller, animated: true)
    }
    
    @objc
    private func filterButtonAction() {
        UISelectionFeedbackGenerator().selectionChanged()
        
        stopRefreshTimer()
        
        let controller = DJLLogFilterViewController(settings: settings)
        let navController = UINavigationController(rootViewController: controller)
        navController.presentationController?.delegate = self
        present(navController, animated: true)
    }
    
    @objc
    private func playPauseButtonAction() {
        UISelectionFeedbackGenerator().selectionChanged()
        
        settings.isPaused.toggle()
        setupBarButtonItems()
    }
    
    @objc
    private func trashButtonAction() {
        
        UISelectionFeedbackGenerator().selectionChanged()
        
        stopRefreshTimer()
        
        let controller = UIAlertController(title: "Clear All Logs", message: nil, preferredStyle: .alert)

        controller.addAction(UIAlertAction(title: "Yes", style: .destructive) { _ in
            
            self.clearAllLogs()
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
    
    private func clearAllLogs() {
        
        stopRefreshTimer()
        
        let controller = UIAlertController(title: "Removing Logs...", message: nil, preferredStyle: .alert)
        self.present(controller, animated: true) {
            
            DJLFileReader.removeAllLogFiles {
                
                DispatchQueue.main.async {
                    
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    
                    self.sections.removeAll()
                    self.tableView.reloadData()
                    
                    self.refreshLogs()
                    self.refreshLogUsage()
                    self.startRefreshTimer()
                    
                    controller.dismiss(animated: true)
                }
            }
        }
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
                    let description = item.logText()
                    UIPasteboard.general.string = description
                }
            ])
            return UIMenu(title: "Log", children: [
                UIAction(title: "Share") { [weak self] _ in
                    let description = item.logText()
                    let controller = UIActivityViewController(activityItems: [description], applicationActivities: nil)
                    self?.present(controller, animated: true)
                },
                UIAction(title: "Open log file") { [weak self] _ in
                    if let self = self {
                        let preview = DJLPreviewHandler(items: [.init(title: item.label, url: item.fileURL)])
                        preview.present(parent: self)
                    }
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
        
        refreshLogs()
        setupBarButtonItems()
        startRefreshTimer()
    }
}

#endif
