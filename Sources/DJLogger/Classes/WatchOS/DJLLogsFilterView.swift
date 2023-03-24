#if os(watchOS)
//
//  DJLLogsFilterView.swift
//  DJLogger-watchOS
//
//  Created by David Jonsén on 2022-12-06.
//

import SwiftUI

struct DJLLogsFilterView: View {
    
    @Environment(\.dismiss)
    private var dismiss
    
    @ObservedObject
    private var settings: DJLLogFilterSettings
    
    @State
    private var sections: [DJLLogFilterSection] = []
    
    init(settings: DJLLogFilterSettings) {
        self.settings = settings
        
        let items = DJLLogger
            .Level
            .allCases
            .compactMap {
                DJLLogFilterRow(title: $0.name,
                                group: String(describing: DJLLogger.Level.self),
                                type: .checkmark)
            }
        
        var sections = [
            DJLLogFilterSection(
                title: "Level",
                items: items)
        ]
        
        if settings.labels.isEmpty == false {
            let section = DJLLogFilterSection(title: "Labels", items: settings.labels.compactMap { DJLLogFilterRow(title: $0, group: "Labels", type: .checkmark) })
            sections.append(section)
        }
        
        _sections = .init(initialValue: sections)
    }
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                
                ForEach(sections) { section in
                    
                    Section {
                        
                        VStack {
                            
                            ForEach(section.items) { item in
                                
                                Button {
                                    
                                    if item.group == String(describing: DJLLogger.Level.self) {
                                        settings.toggleLevel(item.title)
                                    } else if item.group == "Labels" {
                                        if let index = settings.selectedLabels.firstIndex(of: item.title) {
                                            settings.selectedLabels.remove(at: index)
                                        } else {
                                            settings.selectedLabels.append(item.title)
                                        }
                                    }
                                    
                                } label: {
                                    
                                    HStack {
                                        
                                        Text(item.title)
                                        
                                        Spacer()
                                        
                                        if item.group == String(describing: DJLLogger.Level.self) {
                                            
                                            if settings.levels.compactMap({ $0.name }).contains(item.title) {
                                                Image(systemName: "checkmark")
                                            }
                                        } else if item.group == "Labels" {
                                            if settings.selectedLabels.compactMap({ $0 }).contains(item.title) {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            }
                        }

                    } header: {
                        
                        Text(section.title)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .toolbar {
            
            ToolbarItem(placement: .confirmationAction) {
                
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(.blue)
            }
        }
        .navigationBarTitle("Filters")
    }
}

struct DJLLogsFilterView_Previews: PreviewProvider {

    static var previews: some View {

        DJLLogsFilterView(settings: DJLLogFilterSettings())
    }
}
#endif
