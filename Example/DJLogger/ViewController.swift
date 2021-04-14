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
import DJLogger
import UIKit

class ViewController: UIViewController {
    
    private let logger = DJLLogger("View", [DJLConsoleHandler(), DJLFileHandler("app")])
    private let backgroundLogger = DJLLogger("Background", [DJLConsoleHandler(), DJLFileHandler("background")])
    private let repeatingLogger = DJLLogger("Repeating", [DJLConsoleHandler(), DJLFileHandler("repeater")])
            
    private var cancelBag = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        logger.debug("View Did Load")

        becomeFirstResponder()
        
        startAutomatedTestLogs()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.presentDJLLogViewController()
        }
    }

    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            UISelectionFeedbackGenerator().selectionChanged()
            presentDJLLogViewController()
        }
    }
    
    private func startAutomatedTestLogs() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.backgroundLogger.warning("Ohhh noooo!! 🤦‍♂️")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            self.backgroundLogger.error("🧨")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.backgroundLogger.critical("💥")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            self.backgroundLogger.trace("🥳")
        }
        
        Timer
            .publish(every: 20, on: .main, in: .commonModes)
            .autoconnect()
            .sink { [weak self] _ in
                
                if [true, false].randomElement()! {
                    self?.repeatingLogger.warning("Every 20 seconds!")
                } else {
                    self?.repeatingLogger.debug("Every 20 seconds!")
                }
            }
            .store(in: &cancelBag)
       
    }
    
    private func presentDJLLogViewController() {
        
        logger.trace("🚀 Present Log View Controller")
        
        let controller = DJLLogViewController()
        let navController = UINavigationController(rootViewController: controller)
        present(navController, animated: true) {
            self.logger.trace("👍 Presented Log View Controller")
        }
    }
}
