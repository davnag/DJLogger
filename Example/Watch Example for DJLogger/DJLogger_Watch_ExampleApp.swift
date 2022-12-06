//
//  DJLogger_Watch_ExampleApp.swift
//  DJLogger_Watch_Example Watch App
//
//  Created by David Jonsén on 2022-12-05.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import SwiftUI
import DJLogger

@main
struct DJLogger_Watch_Example: App {
    
    @State
    private var logger = DJLLogger("App", [DJLConsoleHandler(), DJLFileHandler("Watch")])
    
    var body: some Scene {
        
        WindowGroup {
            ContentView()
                .onAppear {
                    logger.trace("On Appear")
                }
        }
    }
}
