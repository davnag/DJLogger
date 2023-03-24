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

public final class DJLLogFilterViewController: UITableViewController {
    
    private let settings: DJLLogFilterSettings
    private var sections: [DJLLogFilterSection] = []

    public init(settings: DJLLogFilterSettings) {
        self.settings = settings
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        sections = [
            DJLLogFilterSection(title: "Level", items: DJLLogger.Level.allCases.compactMap { DJLLogFilterRow(title: $0.name, group: String(describing: DJLLogger.Level.self), type: .checkmark) })
        ]
        
        if settings.labels.isEmpty == false {
            let section = DJLLogFilterSection(title: "Labels", items: settings.labels.compactMap { DJLLogFilterRow(title: $0, group: "Labels", type: .checkmark) })
            self.sections.append(section)
        }

        setupViewController()
    }
}

// MARK: - Setup

extension DJLLogFilterViewController {

    func setupViewController() {

        title = "Filters"
        navigationController?.navigationBar.prefersLargeTitles = false

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "xmark.circle.fill"), style: .plain, target: self, action: #selector(actionCloseButton))
        ]
    }
}

// MARK: - Actions

extension DJLLogFilterViewController {
    
    @objc
    private func actionCloseButton() {

        if let presentationController = self.navigationController?.presentationController {
            presentationController.delegate?.presentationControllerWillDismiss?(presentationController)
        }
        
        dismiss(animated: true)
    }
}

// MARK: - UITableVievDelegate, UITableViewDataSource

extension DJLLogFilterViewController {
    
    override public func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].items.count
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        let item = sections[indexPath.section].items[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        if item.group == String(describing: DJLLogger.Level.self) {
            
            if settings.levels.compactMap({ $0.name }).contains(item.title) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        } else if item.group == "Labels" {
            if settings.selectedLabels.compactMap({ $0 }).contains(item.title) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        
        return cell
    }
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        UISelectionFeedbackGenerator().selectionChanged()
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        let cell = tableView.cellForRow(at: indexPath)
        let item = sections[indexPath.section].items[indexPath.row]
        
        switch item.type {
        case .checkmark:
            
            if cell?.accessoryType == .checkmark {
                cell?.accessoryType = .none
            } else {
                cell?.accessoryType = .checkmark
            }
            
            if item.group == String(describing: DJLLogger.Level.self) {
                if let level = DJLLogger.Level(rawValue: indexPath.row) {
                    if let index = settings.levels.firstIndex(of: level) {
                        settings.levels.remove(at: index)
                    } else {
                        settings.levels.append(level)
                    }
                }
            } else if item.group == "Labels" {
                if let index = settings.selectedLabels.firstIndex(of: item.title) {
                    settings.selectedLabels.remove(at: index)
                } else {
                    settings.selectedLabels.append(item.title)
                }
            }
        }
    }
    
    override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}

#endif
