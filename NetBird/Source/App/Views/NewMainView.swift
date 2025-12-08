//
//  NewMainView.swift
//  Ryvie Connect
//
//  Created on 05.12.24.
//

import SwiftUI

struct NewMainView: View {
    @EnvironmentObject var viewModel: ViewModel
    @State private var showMenu = false
    @State private var isLoading = true
    @State private var forceOnboarding = false
    @State private var showPeersList = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if isLoading {
                    // Loading screen
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.36, green: 0.84, blue: 0.95),
                                Color(red: 0.20, green: 0.60, blue: 0.80)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            Image("logo-onboarding")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120)
                            
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                        }
                    }
                } else if !viewModel.statusDetailsValid || forceOnboarding {
                    // Show onboarding if no setup key configured
                    OnboardingView()
                        .onAppear {
                            forceOnboarding = false
                        }
                } else {
                    // Main connected view
                    mainConnectedView
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                checkInitialState()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func checkInitialState() {
        // Vérifier si une configuration valide existe
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let hasValidConfig = viewModel.hasValidConfiguration()
            
            print("🔍 [NewMainView] Has valid configuration: \(hasValidConfig)")
            
            if hasValidConfig {
                // Configuration valide existe, vérifier l'état de l'extension
                viewModel.statusDetailsValid = true
                viewModel.checkExtensionState()
            } else {
                // Pas de configuration valide, afficher l'onboarding
                viewModel.statusDetailsValid = false
            }
            
            isLoading = false
        }
    }
    
    private var mainConnectedView: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.97, blue: 0.99),
                    Color(red: 0.90, green: 0.94, blue: 0.98)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                Spacer()
                
                // Connection Status
                connectionStatusCard
                
                Spacer()
                
                // Connect Button
                ModernConnectButton(
                    isConnected: .constant(viewModel.extensionState == .connected),
                    isConnecting: .constant(viewModel.extensionState == .connecting),
                    action: toggleConnection
                )
                .padding(.bottom, 40)
                
                // Peers List
                if viewModel.extensionState == .connected {
                    peersList
                        .transition(.opacity.combined(with: .scale))
                }
                
                Spacer()
            }
            
            // Side Menu
            if showMenu {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showMenu = false
                        }
                    }
                
                HStack {
                    modernSideMenu
                        .transition(.move(edge: .leading))
                    Spacer()
                }
            }
        }
    }
    
    private var header: some View {
        HStack {
            Button(action: {
                withAnimation(.spring()) {
                    showMenu.toggle()
                }
            }) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 0.36, green: 0.84, blue: 0.95))
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            Image("logo-onboarding")
                .resizable()
                .scaledToFit()
                .frame(height: 40)
            
            Spacer()
            
            // Bouton pour supprimer la setup key
            Button(action: {
                deleteSetupKey()
            }) {
                Image(systemName: "trash")
                    .font(.system(size: 20))
                    .foregroundColor(.red)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 50)
    }
    
    private var connectionStatusCard: some View {
        VStack(spacing: 16) {
            // Status badge
            HStack(spacing: 8) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 12, height: 12)
                    .shadow(color: statusColor, radius: 4)
                
                Text(statusTitle)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            if viewModel.extensionState == .connected {
                VStack(spacing: 12) {
                    Button(action: {
                        UIPasteboard.general.string = viewModel.fqdn
                        viewModel.showFqdnCopiedAlert = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            viewModel.showFqdnCopiedAlert = false
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "network")
                                .font(.system(size: 18))
                                .foregroundColor(Color(red: 0.36, green: 0.84, blue: 0.95))
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("FQDN")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color(red: 0.36, green: 0.84, blue: 0.95))
                                Text(viewModel.fqdn)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color(red: 0.20, green: 0.60, blue: 0.80))
                            }
                            Spacer()
                            
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14))
                                .foregroundColor(Color(red: 0.36, green: 0.84, blue: 0.95))
                        }
                        .padding(12)
                        .background(Color(red: 0.36, green: 0.84, blue: 0.95).opacity(0.15))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        UIPasteboard.general.string = viewModel.ip
                        viewModel.showIpCopiedAlert = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            viewModel.showIpCopiedAlert = false
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "globe")
                                .font(.system(size: 18))
                                .foregroundColor(Color(red: 0.30, green: 0.85, blue: 0.40))
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("IP Address")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color(red: 0.30, green: 0.85, blue: 0.40))
                                Text(viewModel.ip)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color(red: 0.20, green: 0.60, blue: 0.30))
                            }
                            Spacer()
                            
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14))
                                .foregroundColor(Color(red: 0.30, green: 0.85, blue: 0.40))
                        }
                        .padding(12)
                        .background(Color(red: 0.30, green: 0.85, blue: 0.40).opacity(0.15))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.top, 8)
                .transition(.opacity.combined(with: .scale))
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal, 30)
    }
    
    private var peersList: some View {
        Button(action: {
            showPeersList = true
        }) {
            HStack {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 0.36, green: 0.84, blue: 0.95))
                
                Text("Peers connectés")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                Text("\(viewModel.peerViewModel.peerInfo.filter { $0.connStatus == "Connected" }.count)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(red: 0.36, green: 0.84, blue: 0.95))
                    .cornerRadius(12)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 30)
        .padding(.bottom, 20)
        .sheet(isPresented: $showPeersList) {
            PeersListView()
                .environmentObject(viewModel)
        }
    }
    
    private var modernSideMenu: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Menu Header
            VStack(alignment: .leading, spacing: 8) {
                Image("logo-onboarding")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
                
                Text("Ryvie Connect")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(30)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.36, green: 0.84, blue: 0.95),
                        Color(red: 0.20, green: 0.60, blue: 0.80)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
            // Menu Items
            VStack(alignment: .leading, spacing: 0) {
                NavigationLink(destination: SetupKeyView()) {
                    HStack(spacing: 15) {
                        Image(systemName: "key.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 0.36, green: 0.84, blue: 0.95))
                            .frame(width: 30)
                        
                        Text("Setup Key")
                            .font(.system(size: 18))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 20)
                }
                
                Divider()
                    .background(Color.gray.opacity(0.2))
                
                MenuButton(icon: "plus.circle.fill", title: "Nouvelle Connexion", action: {
                    showMenu = false
                    viewModel.clearDetails()
                })
                
                Divider()
                    .background(Color.gray.opacity(0.2))
                
                NavigationLink(destination: AboutView()) {
                    HStack(spacing: 15) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 0.36, green: 0.84, blue: 0.95))
                            .frame(width: 30)
                        
                        Text("About")
                            .font(.system(size: 18))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 20)
                }
                
                Spacer()
                
                // Version
                Text("Version \(appVersion)")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(30)
            }
            .background(Color.white)
        }
        .frame(width: UIScreen.main.bounds.width * 0.75)
        .shadow(radius: 10)
    }
    
    private var statusTitle: String {
        switch viewModel.extensionState {
        case .connected:
            return "Connecté"
        case .connecting:
            return "Connexion..."
        case .disconnecting:
            return "Déconnexion..."
        default:
            return "Déconnecté"
        }
    }
    
    private var statusColor: Color {
        switch viewModel.extensionState {
        case .connected:
            return Color(red: 0.30, green: 0.85, blue: 0.40)
        case .connecting, .disconnecting:
            return Color(red: 0.95, green: 0.70, blue: 0.30)
        default:
            return Color.gray
        }
    }
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    }
    
    private func toggleConnection() {
        if viewModel.extensionState == .connected {
            viewModel.close()
        } else if viewModel.extensionState == .disconnected {
            viewModel.connect()
        }
    }
    
    private func deleteSetupKey() {
        print("🗑️ [NewMainView] Deleting setup key")
        
        // Déconnecter si connecté
        if viewModel.extensionState != .disconnected {
            viewModel.close()
        }
        
        // Effacer la configuration
        viewModel.clearDetails()
        
        // Forcer la redirection vers l'onboarding
        forceOnboarding = true
        
        print("✅ [NewMainView] Setup key deleted, redirecting to onboarding")
    }
}

struct PeersListView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var connectedPeers: [PeerInfo] {
        viewModel.peerViewModel.peerInfo.filter { $0.connStatus == "Connected" }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.95, green: 0.97, blue: 0.99),
                        Color(red: 0.90, green: 0.94, blue: 0.98)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Retour")
                                    .font(.system(size: 17))
                            }
                            .foregroundColor(Color(red: 0.36, green: 0.84, blue: 0.95))
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
                    // Title
                    HStack {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color(red: 0.36, green: 0.84, blue: 0.95))
                        
                        Text("Peers connectés")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    
                    // Peers count
                    HStack {
                        Text("\(connectedPeers.count) peer\(connectedPeers.count > 1 ? "s" : "") connecté\(connectedPeers.count > 1 ? "s" : "")")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                    
                    // Peers list
                    if connectedPeers.isEmpty {
                        Spacer()
                        VStack(spacing: 20) {
                            Image(systemName: "person.2.slash")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text("Aucun peer connecté")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.gray)
                            
                            Text("Les appareils connectés apparaîtront ici")
                                .font(.system(size: 16))
                                .foregroundColor(.gray.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 40)
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(connectedPeers, id: \.ip) { peer in
                                    PeerRowView(peer: peer)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct PeerRowView: View {
    let peer: PeerInfo
    
    var deviceName: String {
        if !peer.fqdn.isEmpty {
            // Extraire le nom de l'appareil du FQDN (avant le premier point)
            let name = peer.fqdn.components(separatedBy: ".").first ?? peer.fqdn
            // Si c'est une IP, retourner un nom par défaut
            if name.contains(":") || name.split(separator: ".").count == 4 {
                return "Peer \(peer.ip.suffix(3))"
            }
            return name
        }
        return "Peer \(peer.ip.suffix(3))"
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            Circle()
                .fill(peer.connStatus == "Connected" ? Color(red: 0.30, green: 0.85, blue: 0.40) : Color.gray)
                .frame(width: 10, height: 10)
                .shadow(color: peer.connStatus == "Connected" ? Color(red: 0.30, green: 0.85, blue: 0.40) : Color.gray, radius: 3)
            
            // Device icon
            ZStack {
                Circle()
                    .fill(Color(red: 0.36, green: 0.84, blue: 0.95).opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "laptopcomputer")
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 0.36, green: 0.84, blue: 0.95))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(deviceName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                
                HStack(spacing: 8) {
                    Text(peer.ip)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    
                    if peer.relayed {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 10))
                            Text("Relayed")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(.orange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.15))
                        .cornerRadius(6)
                    } else if peer.direct {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 10))
                            Text("Direct")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(Color(red: 0.30, green: 0.85, blue: 0.40))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(red: 0.30, green: 0.85, blue: 0.40).opacity(0.15))
                        .cornerRadius(6)
                    }
                }
            }
            
            Spacer()
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 3)
    }
}

struct MenuButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 0.36, green: 0.84, blue: 0.95))
                    .frame(width: 30)
                
                Text(title)
                    .font(.system(size: 18))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 20)
        }
    }
}

#Preview {
    NewMainView()
        .environmentObject(ViewModel())
}
