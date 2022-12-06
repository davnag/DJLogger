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
    private var isPresentingRemoveLogsDialog: Bool = false
    
    @StateObject
    private var viewModel: DJLLogsViewModel
    
    public init() {
        _viewModel = StateObject(wrappedValue: DJLLogsViewModel())
    }
    
    public var body: some View {
        
        NavigationStack {
            
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

struct DJLLogsView_Previews: PreviewProvider {
    static var previews: some View {
        DJLLogsView()
    }
}
