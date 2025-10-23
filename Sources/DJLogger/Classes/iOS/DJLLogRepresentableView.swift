#if os(iOS)
import UIKit
import SwiftUI

public struct DJLLogRepresentableView: UIViewControllerRepresentable {
    public typealias UIViewControllerType = UIViewController
    
    public init() { }
    
    public func makeUIViewController(context: Context) -> UIViewController {
        let controller = DJLLogViewController()
        return UINavigationController(rootViewController: controller)
    }
    
    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Updates the state of the specified view controller with new information from SwiftUI.
    }
}

// MARK: - Previews

#Preview {
    DJLLogRepresentableView()
}
#endif
