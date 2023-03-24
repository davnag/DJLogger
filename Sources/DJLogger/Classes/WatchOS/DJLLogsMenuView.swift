#if os(watchOS)
//
//  DJLLogsMenuView.swift
//  DJLogger-watchOS
//
//  Created by David Jonsén on 2023-01-20.
//

import SwiftUI

struct DJLLogsMenuView: View {
    
    private enum MenuAction {
        case none
        case filter
        case share
        case clear
    }
    
    @State
    private var menuAction: MenuAction = .none
    
    @Environment(\.dismiss)
    private var dismiss
    
    var filterAction: () -> Void
    
    var shareAction: () -> Void
    
    var clearAction: () -> Void

    init(filterAction: @escaping () -> Void, shareAction: @escaping () -> Void, clearAction: @escaping () -> Void) {
        self.filterAction = filterAction
        self.shareAction = shareAction
        self.clearAction = clearAction
    }
    
    var body: some View {
        
        ScrollView {
            
            Button {
                menuAction = .filter
                dismiss()
            } label: {
                Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
            }

            Button {
                menuAction = .share
                dismiss()
            } label: {
                Label("Share Logs", systemImage: "square.and.arrow.up")
            }
            
            Button(role: .destructive) {
                menuAction = .clear
                dismiss()
            } label: {
                Label("Clear Logs", systemImage: "trash")
            }

            Button("Cancel", role: .cancel) {
                dismiss()
            }
            .padding(.top)
        }
        .onDisappear {
            
            switch menuAction {
            case .filter:
                filterAction()
            case .share:
                shareAction()
            case .clear:
                clearAction()
            default:
                break
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Menu")
    }
}

//struct DJLLogsMenuView_Previews: PreviewProvider {
//    static var previews: some View {
//        DJLLogsMenuView()
//    }
//}
#endif
