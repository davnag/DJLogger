#if os(watchOS)
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

import SwiftUI

public struct DJLLogsView: View {
    
    @Environment(\.dismiss)
    private var dismiss
    
    @State
    private var isPresentingMenuDialog: Bool = false

    @State
    private var isPresentingDeleteAllLogsDialog: Bool = false
    
    @State
    private var isPresentingFiltersSheet: Bool = false
    
    @State
    private var isPresentingShareSheet: Bool = false

    @StateObject
    private var viewModel: DJLLogsViewModel
    
    public init() {
        _viewModel = StateObject(wrappedValue: DJLLogsViewModel())
    }
    
    public var body: some View {
        
        NavigationStack {
            
            Group {

                if viewModel.sections.isEmpty {
                    
                    Text("No Logs")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                } else {
                    
                    ScrollView {
                        
                        LazyVStack {
                            
                            ForEach(viewModel.sections) { section in
                                
                                Section {
                                    
                                    ForEach(section.items) { log in
                                        DJLLogView(log: log)
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
                }
            }
            .navigationTitle("Logs")
            .toolbar {
                
                ToolbarItemGroup(placement: .cancellationAction) {
                    
                    Button("Close", role: .cancel) {
                        
                        dismiss()
                    }
                }
                
                ToolbarItemGroup(placement: .confirmationAction) {

                    Button {
                        isPresentingMenuDialog = true
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .foregroundColor(.blue)
                }
            }
            .onAppear {
                viewModel.refreshLogs()
                viewModel.startRefreshTimer()
            }
            .onDisappear {
                viewModel.stopRefreshTimer()
            }
            .sheet(isPresented: $isPresentingMenuDialog) {
                
                DJLLogsMenuView {
                    isPresentingFiltersSheet = true
                } shareAction: {
                    isPresentingShareSheet = true
                } clearAction: {
                    isPresentingDeleteAllLogsDialog = true
                }
            }
            .sheet(isPresented: $isPresentingFiltersSheet) {
                
                DJLLogsFilterView(settings: viewModel.settings)
            }
            .sheet(isPresented: $isPresentingShareSheet) {
                
                DJLLogsShareMenuView(viewModel: viewModel)
            }
            .confirmationDialog("Do you want to clear all logs?", isPresented: $isPresentingDeleteAllLogsDialog) {
                
                Button("Yes", role: .destructive) {
                    self.viewModel.clearLogs()
                }
            }
        }
    }
}

// MARK: - Previews

struct DJLLogsView_Previews: PreviewProvider {
    static var previews: some View {
        DJLLogsView()
    }
}
#endif
