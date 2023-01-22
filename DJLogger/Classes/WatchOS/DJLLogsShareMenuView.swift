//
//  DJLLogsShareMenuView.swift
//  DJLogger-watchOS
//
//  Created by David Jonsén on 2023-01-20.
//

import SwiftUI

struct DJLLogsShareMenuView: View {
    
    @Environment(\.dismiss)
    private var dismiss
    
    @ObservedObject
    var viewModel: DJLLogsViewModel
    
    @State
    private var files: [DJLLogsViewModel.DJSharableLogFile] = []
    
    var body: some View {
        
        NavigationStack {
            
            List {
                
                ForEach(files) { file in
                    
                    ShareLink(item: file.text()) {
                        Text(file.name)
                            .font(.headline)
                    }
                }
            }
            .toolbar {
                
                ToolbarItem(placement: .cancellationAction) {
                    
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .navigationTitle("Share")
            .onAppear {
                self.files = viewModel.files()
            }
        }
    }
}

//struct DJLLogsShareMenuView_Previews: PreviewProvider {
//    static var previews: some View {
//        DJLLogsShareMenuView()
//    }
//}
