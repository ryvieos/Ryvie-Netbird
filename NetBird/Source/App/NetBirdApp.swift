//
//  RyvieConnectApp.swift
//  Ryvie Connect
//
//  Created by Pascal Fischer on 01.08.23.
//

import SwiftUI

@main
struct RyvieConnectApp: App {
    @StateObject var viewModel = ViewModel()
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            NewMainView()
                .environmentObject(viewModel)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) {_ in
                    print("App is active!")
                    viewModel.checkExtensionState()
                    viewModel.startPollingDetails()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) {_ in
                    print("App is inactive!")
                    viewModel.stopPollingDetails()
                }
        }
    }
}
