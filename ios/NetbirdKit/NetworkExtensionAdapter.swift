//
//  NetworkExtensionAdapter.swift
//  NetBirdiOS
//
//  Created by Pascal Fischer on 02.10.23.
//

import Foundation
import NetworkExtension
import SwiftUI

public class NetworkExtensionAdapter: ObservableObject {
        
    var session : NETunnelProviderSession?
    var vpnManager: NETunnelProviderManager?
    
    var extensionID = "ryvie.netbird.app.NetbirdNetworkExtension"
    var extensionName = "NetBird Network Extension"
    
    let decoder = PropertyListDecoder()    
    
    @Published var timer : Timer
    
    @Published var showBrowser = false
    @Published var loginURL : String?
    
    init() {
        self.timer = Timer()
        self.timer.invalidate()
        Task {
            do {
                try await self.configureManager()
            } catch {
                print("Failed to configure manager")
            }
        }
    }
    
    deinit {
        self.timer.invalidate()
    }
    
    func start() async {
        print("🚀 [NetworkExtensionAdapter] start() called")
        do {
            print("⚙️ [NetworkExtensionAdapter] Configuring manager...")
            try await configureManager()
            print("✅ [NetworkExtensionAdapter] Extension configured successfully")
            
            // Observer les changements de status
            NotificationCenter.default.addObserver(
                forName: .NEVPNStatusDidChange,
                object: self.vpnManager?.connection,
                queue: .main
            ) { notification in
                if let connection = notification.object as? NEVPNConnection {
                    print("🔔 [NetworkExtensionAdapter] VPN Status changed to: \(connection.status.rawValue)")
                    switch connection.status {
                    case .invalid:
                        print("   Status: INVALID")
                    case .disconnected:
                        print("   Status: DISCONNECTED")
                    case .connecting:
                        print("   Status: CONNECTING")
                    case .connected:
                        print("   Status: CONNECTED")
                    case .reasserting:
                        print("   Status: REASSERTING")
                    case .disconnecting:
                        print("   Status: DISCONNECTING")
                    @unknown default:
                        print("   Status: UNKNOWN")
                    }
                }
            }
            
            // Observer les erreurs de configuration
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name.NEVPNConfigurationChange,
                object: self.vpnManager,
                queue: .main
            ) { notification in
                print("🔔 [NetworkExtensionAdapter] VPN Configuration changed")
            }
            
            print("🔐 [NetworkExtensionAdapter] Checking if login is required...")
            await loginIfRequired()
            print("✅ [NetworkExtensionAdapter] start() completed")
        } catch {
            print("❌ [NetworkExtensionAdapter] Failed to start extension: \(error)")
            print("❌ [NetworkExtensionAdapter] Error details: \(error.localizedDescription)")
        }
    }

    private func configureManager() async throws {
        let managers = try await NETunnelProviderManager.loadAllFromPreferences()
        if let manager = managers.first(where: { $0.localizedDescription == self.extensionName }) {
            self.vpnManager = manager
        } else {
            let newManager = createNewManager()
            try await newManager.saveToPreferences()
            self.vpnManager = newManager
        }
        self.vpnManager?.isEnabled = true
        try await self.vpnManager?.saveToPreferences()
        try await self.vpnManager?.loadFromPreferences()
        self.session = self.vpnManager?.connection as? NETunnelProviderSession
    }

    private func createNewManager() -> NETunnelProviderManager {
        let tunnelProviderProtocol = NETunnelProviderProtocol()
        tunnelProviderProtocol.providerBundleIdentifier = self.extensionID
        tunnelProviderProtocol.serverAddress = "multiple endpoints"
        
        let newManager = NETunnelProviderManager()
        newManager.protocolConfiguration = tunnelProviderProtocol
        newManager.localizedDescription = self.extensionName
        newManager.isEnabled = true

        return newManager
    }
    


    public func loginIfRequired() async {
        if self.isLoginRequired() {
            print("require login")
            
            await performLogin()
        } else {
            startVPNConnection()
        }

        print("will start vpn connection")
    }
    
    public func isLoginRequired() -> Bool {
        guard let client = NetBirdSDKNewClient(Preferences.configFile(), Preferences.stateFile(), Device.getName(), Device.getOsVersion(), Device.getOsName(), nil, nil) else {
            print("Failed to initialize client")
            return true
        }
        return client.isLoginRequired()
    }

    class ObserverBox {
        var observer: NSObjectProtocol?
    }

    private func performLogin() async {
        let loginURLString = await withCheckedContinuation { continuation in
            self.login { urlString in
                print("urlstring: \(urlString)")
                continuation.resume(returning: urlString)
            }
        }
        
        self.loginURL = loginURLString
        self.showBrowser = true
    }

    public func startVPNConnection() {
        print("🚀 [NetworkExtensionAdapter] startVPNConnection() called")
        
        guard let session = self.session else {
            print("❌ [NetworkExtensionAdapter] No session available!")
            return
        }
        
        print("✅ [NetworkExtensionAdapter] Session available: \(session)")
        print("🔍 [NetworkExtensionAdapter] Session status: \(session.status)")
        
        let logLevel = UserDefaults.standard.string(forKey: "logLevel") ?? "INFO"
        print("📝 [NetworkExtensionAdapter] Log level: \(logLevel)")
        let options: [String: NSObject] = ["logLevel": logLevel as NSObject]
        
        do {
            print("⏳ [NetworkExtensionAdapter] Calling startVPNTunnel...")
            try session.startVPNTunnel(options: options)
            print("✅ [NetworkExtensionAdapter] VPN Tunnel start command sent successfully")
            
            // Attendre un peu et vérifier le status
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                print("🔍 [NetworkExtensionAdapter] Status after 2s: \(session.status.rawValue)")
                if session.status == .invalid {
                    print("❌ [NetworkExtensionAdapter] Status is INVALID - extension not configured properly")
                } else if session.status == .disconnected {
                    print("⚠️ [NetworkExtensionAdapter] Status still DISCONNECTED - extension failed to start")
                } else if session.status == .connecting {
                    print("⏳ [NetworkExtensionAdapter] Status is CONNECTING - waiting...")
                } else if session.status == .connected {
                    print("✅ [NetworkExtensionAdapter] Status is CONNECTED!")
                }
            }
        } catch let error {
            print("❌ [NetworkExtensionAdapter] Failed to start VPN tunnel: \(error)")
            print("❌ [NetworkExtensionAdapter] Error details: \(error.localizedDescription)")
        }
    }

    
    func stop() -> Void {
        self.vpnManager?.connection.stopVPNTunnel()
    }
    
    func login(completion: @escaping (String) -> Void) {
        if self.session == nil {
            print("No session available for login")
            return
        }

        do {
            let messageString = "Login"
            if let messageData = messageString.data(using: .utf8) {
                // Send the message to the network extension
                try self.session!.sendProviderMessage(messageData) { response in
                    if let response = response {
                        if let string = String(data: response, encoding: .utf8) {
                            completion(string)
                            return
                        }
                    }
                }
            } else {
                print("Error converting message to Data")
            }
        } catch {
            print("error when performing network extension action")
        }
    }
    
    func getRoutes(completion: @escaping (RoutesSelectionDetails) -> Void) {
        guard let session = self.session else {
            let defaultStatus = RoutesSelectionDetails(all: false, append: false, routeSelectionInfo: [])
            completion(defaultStatus)
            return
        }
        
        let messageString = "GetRoutes"
        if let messageData = messageString.data(using: .utf8) {
            do {
                try session.sendProviderMessage(messageData) { response in
                    if let response = response {
                        do {
                            let decodedStatus = try self.decoder.decode(RoutesSelectionDetails.self, from: response)
                            completion(decodedStatus)
                            return
                        } catch {
                            print("Failed to decode route selection details.")
                        }
                    } else {
                        let defaultStatus = RoutesSelectionDetails(all: false, append: false, routeSelectionInfo: [])
                        completion(defaultStatus)
                        return
                    }
                }
            } catch {
                print("Failed to send Provider message")
            }
        } else {
            print("Error converting message to Data")
        }
    }
    
    func selectRoutes(id: String, completion: @escaping (RoutesSelectionDetails) -> Void) {
        guard let session = self.session else {
            return
        }
        
        let messageString = "Select-\(id)"
        if let messageData = messageString.data(using: .utf8) {
            do {
                try session.sendProviderMessage(messageData) { response in
                    let routes = RoutesSelectionDetails(all: false, append: false, routeSelectionInfo: [])
                    completion(routes)
                }
            } catch {
                print("Failed to send Provider message")
            }
        } else {
            print("Error converting message to Data")
        }
    }
    
    func deselectRoutes(id: String, completion: @escaping (RoutesSelectionDetails) -> Void) {
        guard let session = self.session else {
            return
        }
        
        let messageString = "Deselect-\(id)"
        if let messageData = messageString.data(using: .utf8) {
            do {
                try session.sendProviderMessage(messageData) { response in
                    let routes = RoutesSelectionDetails(all: false, append: false, routeSelectionInfo: [])
                    completion(routes)
                }
            } catch {
                print("Failed to send Provider message")
            }
        } else {
            print("Error converting message to Data")
        }
    }
    
    func fetchData(completion: @escaping (StatusDetails) -> Void) {
        guard let session = self.session else {
            let defaultStatus = StatusDetails(ip: "", fqdn: "", managementStatus: .disconnected, peerInfo: [])
            completion(defaultStatus)
            return
        }
        
        let messageString = "Status"
        if let messageData = messageString.data(using: .utf8) {
            do {
                try session.sendProviderMessage(messageData) { response in
                    if let response = response {
                        do {
                            let decodedStatus = try self.decoder.decode(StatusDetails.self, from: response)
                            completion(decodedStatus)
                            return
                        } catch {
                            print("Failed to decode status details.")
                        }
                    } else {
                        let defaultStatus = StatusDetails(ip: "", fqdn: "", managementStatus: .disconnected, peerInfo: [])
                        completion(defaultStatus)
                        return
                    }
                }
            } catch {
                print("Failed to send Provider message")
            }
        } else {
            print("Error converting message to Data")
        }
    }
    
    func startTimer(completion: @escaping (StatusDetails) -> Void) {
        self.timer.invalidate()
        self.fetchData(completion: completion)
        self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { _ in
            self.fetchData(completion: completion)
        })
    }
    
    func stopTimer() {
        self.timer.invalidate()
    }

    func getExtensionStatus(completion: @escaping (NEVPNStatus) -> Void) {
        Task {
            do {
                let managers = try await NETunnelProviderManager.loadAllFromPreferences()
                if let manager = managers.first(where: { $0.localizedDescription == self.extensionName }) {
                    completion(manager.connection.status)
                }
            } catch {
                print("Error loading from preferences: \(error)")
            }
        }
    }
}
