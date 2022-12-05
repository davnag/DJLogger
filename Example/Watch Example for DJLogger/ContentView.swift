//
//  ContentView.swift
//  DJLogger_Watch_Example Watch App
//
//  Created by David Jonsén on 2022-12-05.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import SwiftUI
import DJLogger

final class ContentViewModel: ObservableObject {
    
    private let logger = DJLLogger("ContentViewModel", [DJLConsoleHandler(), DJLFileHandler("Watch")])
    
    init() {
        logger.trace("ContentViewModel init")
    }
    
    func log(_ message: String) {
        logger.debug(message)
    }
}

struct ContentView: View {
    
    @StateObject
    private var viewModel: ContentViewModel
    
    @State
    private var isPresentingsLogsView: Bool = false
    
    init() {
        _viewModel = StateObject(wrappedValue: ContentViewModel())
    }
    
    var body: some View {
        
        VStack {
            
            Spacer ()

            Button("Show Logs") {
                isPresentingsLogsView = true
            }
        }
        .padding()
        .sheet(isPresented: $isPresentingsLogsView) {
            DJLLogView()
        }
        .onAppear {
            viewModel.log("On Appear")
        }
        .onDisappear {
            viewModel.log("On Disappear")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
