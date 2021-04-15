# DJLogger

<!-- [![CI Status](https://img.shields.io/travis/David Jonsén/DJLogger.svg?style=flat)](https://travis-ci.org/David Jonsén/DJLogger) 
[![Version](https://img.shields.io/cocoapods/v/DJLogger.svg?style=flat)](https://cocoapods.org/pods/DJLogger)
[![License](https://img.shields.io/cocoapods/l/DJLogger.svg?style=flat)](https://cocoapods.org/pods/DJLogger)
[![Platform](https://img.shields.io/cocoapods/p/DJLogger.svg?style=flat)](https://cocoapods.org/pods/DJLogger)-->

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

DJLogger is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DJLogger'
```

## Implementation

```ruby
import DJLogger

class ViewController: UIViewController {

    let logger = DJLLogger("My Log", [DJLConsoleHandler(), DJLFileHandler("logfile")])

    override func viewDidLoad() {
        super.viewDidLoad()
        logger.trace("View Did Load")
    }
    
    func requestData() {
    
        logger.debug("Start Requesting Data")
        
        // ...
        
        logger.debug("Data Request Completed")
        
        // or
        
        logger.error("Data Request Failed")
    }

}

```

## Author

David Jonsén

## License

DJLogger is available under the MIT license. See the LICENSE file for more info.
