//
//  OnboardingView.swift
//  Ryvie Connect
//
//  Created on 05.12.24.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var viewModel: ViewModel
    @State private var setupKey: String = ""
    @State private var isConnecting = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var animateLogo = false
    @State private var animateContent = false
    @State private var isFetchingFromRyvie = false
    @State private var showManualInput = false
    @State private var ryvieNotFound = false
    @State private var autoConnecting = false
    @State private var showSuccessMessage = false
    
    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground()
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo
                Image("logo-onboarding")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                    .scaleEffect(animateLogo ? 1.0 : 0.5)
                    .opacity(animateLogo ? 1.0 : 0.0)
                    .rotationEffect(.degrees(animateLogo ? 0 : -180))
                
                // Title
                VStack(spacing: 12) {
                    Text("Bienvenue sur")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(.white.opacity(0.9))
                        .opacity(animateContent ? 1.0 : 0.0)
                        .offset(y: animateContent ? 0 : 20)
                    
                    Text("Ryvie Connect")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(.white)
                        .tracking(1)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .offset(y: animateContent ? 0 : 20)
                }
                
                Spacer()
                
                // État de chargement lors de la récupération depuis Ryvie
                if isFetchingFromRyvie {
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        
                        Text("Recherche de Ryvie local...")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.horizontal, 40)
                    .transition(.opacity.combined(with: .scale))
                } else if autoConnecting {
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        
                        Text("Configuration automatique...")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("Connexion au réseau Ryvie")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.horizontal, 40)
                    .transition(.opacity.combined(with: .scale))
                } else if showSuccessMessage {
                    VStack(spacing: 20) {
                        ZStack {
                            // Cercle de fond animé
                            Circle()
                                .fill(Color(red: 0.30, green: 0.85, blue: 0.40).opacity(0.2))
                                .frame(width: 100, height: 100)
                                .scaleEffect(showSuccessMessage ? 1.2 : 0.8)
                                .animation(.easeOut(duration: 0.6).repeatForever(autoreverses: true), value: showSuccessMessage)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Color(red: 0.30, green: 0.85, blue: 0.40))
                                .scaleEffect(showSuccessMessage ? 1.0 : 0.5)
                                .shadow(color: Color(red: 0.30, green: 0.85, blue: 0.40).opacity(0.5), radius: 10, x: 0, y: 5)
                        }
                        
                        Text("Configuration réussie !")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Connexion à Ryvie...")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.horizontal, 40)
                    .transition(.opacity.combined(with: .scale))
                } else if ryvieNotFound {
                    // Message si Ryvie n'est pas trouvé
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.yellow)
                            Text("Ryvie local non détecté")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        Text("Vous pouvez entrer votre clé manuellement")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                        
                        // Bouton pour réessayer
                        Button(action: {
                            Task {
                                await MainActor.run {
                                    ryvieNotFound = false
                                    showManualInput = false
                                }
                                await tryFetchSetupKeyFromRyvie()
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 14))
                                Text("Réessayer")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(Color(red: 0.36, green: 0.84, blue: 0.95))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 40)
                }
                
                // Setup Key Input (toujours visible ou après échec de récupération)
                if showManualInput || ryvieNotFound {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Clé de configuration")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        HStack {
                            Image(systemName: "key.fill")
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 20)
                            
                            TextField("", text: $setupKey)
                                .placeholder(when: setupKey.isEmpty) {
                                    Text("Entrez votre clé")
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .foregroundColor(.white)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        
                        if !setupKey.isEmpty && !viewModel.isValidSetupKey(setupKey) {
                            HStack {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.red)
                                Text("Format de clé invalide")
                                    .font(.system(size: 14))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    
                    // Connect Button
                    Button(action: {
                        connectWithKey()
                    }) {
                        HStack(spacing: 12) {
                            if isConnecting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 24))
                            }
                            Text(isConnecting ? "Connexion..." : "Se connecter")
                                .font(.system(size: 18, weight: .bold))
                                .tracking(0.5)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.30, green: 0.85, blue: 0.40),
                                    Color(red: 0.20, green: 0.70, blue: 0.30)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: Color(red: 0.30, green: 0.85, blue: 0.40).opacity(0.5), radius: 12, x: 0, y: 6)
                    }
                    .disabled(setupKey.isEmpty || !viewModel.isValidSetupKey(setupKey) || isConnecting)
                    .opacity((setupKey.isEmpty || !viewModel.isValidSetupKey(setupKey) || isConnecting) ? 0.5 : 1.0)
                    .padding(.horizontal, 40)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                
                Spacer()
                
                // Footer
                Text("Sécurisé et privé")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 30)
            }
            
            // Error Alert
            if showError {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showError = false
                    }
                
                VStack(spacing: 20) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    
                    Text("Erreur de connexion")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(errorMessage)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        showError = false
                    }) {
                        Text("OK")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(red: 0.36, green: 0.84, blue: 0.95))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                }
                .padding(30)
                .background(Color(red: 0.1, green: 0.1, blue: 0.15))
                .cornerRadius(20)
                .shadow(radius: 20)
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animateLogo = true
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                animateContent = true
            }
            
            // Tenter de récupérer automatiquement la setup key depuis Ryvie
            Task {
                await tryFetchSetupKeyFromRyvie()
            }
        }
    }
    
    private func tryFetchSetupKeyFromRyvie() async {
        print("🔍 [OnboardingView] Tentative de récupération automatique de la setup key...")
        
        // Afficher l'état de chargement
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.3)) {
                isFetchingFromRyvie = true
            }
        }
        
        // Attendre un peu pour l'animation
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 secondes
        
        // Tenter de récupérer la setup key
        if let fetchedKey = await viewModel.fetchSetupKeyFromRyvie() {
            print("✅ [OnboardingView] Setup key récupérée automatiquement!")
            
            // Transition vers l'état de connexion automatique
            await MainActor.run {
                setupKey = fetchedKey
                withAnimation(.easeInOut(duration: 0.3)) {
                    isFetchingFromRyvie = false
                    autoConnecting = true
                }
            }
            
            // Attendre un peu pour l'animation
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 secondes
            
            // Connecter automatiquement avec la clé récupérée
            await connectWithKeyAsync()
            
        } else {
            print("⚠️ [OnboardingView] Impossible de récupérer la setup key, passage en mode manuel")
            
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isFetchingFromRyvie = false
                    ryvieNotFound = true
                    showManualInput = true
                }
            }
        }
    }
    
    private func connectWithKeyAsync() async {
        print("🔌 [OnboardingView] Connexion automatique en cours...")
        
        await MainActor.run {
            isConnecting = true
        }
        
        // Attendre un peu pour l'animation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 secondes
        
        let serverURL = "https://netbird.ryvie.fr"
        let ssoSupported = viewModel.updateManagementURL(url: serverURL)
        
        if ssoSupported == nil {
            await MainActor.run {
                errorMessage = "Impossible de se connecter au serveur. Vérifiez votre connexion internet."
                showError = true
                isConnecting = false
                autoConnecting = false
            }
            return
        }
        
        // Attendre un peu
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 secondes
        
        do {
            try viewModel.setSetupKey(key: setupKey)
            
            print("✅ [OnboardingView] Setup key saved successfully")
            
            // Afficher le message de succès
            await MainActor.run {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    autoConnecting = false
                    showSuccessMessage = true
                }
                isConnecting = false
            }
            
            
            // Lancer la connexion VPN automatiquement
            print("🚀 [OnboardingView] Lancement de la connexion VPN automatique...")
            
            // Garder l'animation de chargement visible
            await MainActor.run {
                viewModel.connect()
            }
            
            // Attendre que la connexion soit établie ou échoue
            var waitAttempts = 0
            while viewModel.extensionState != .connected && viewModel.extensionState != .disconnected && waitAttempts < 40 {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s
                waitAttempts += 1
            }
            
            // Attendre encore un peu si connecté
            if viewModel.extensionState == .connected {
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1s
            }
            
            print("✅ [OnboardingView] Configuration terminée, transition vers l'écran principal")
            
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) {
                    autoConnecting = false
                }
            }
            
        } catch {
            print("❌ [OnboardingView] Error: \(error.localizedDescription)")
            await MainActor.run {
                errorMessage = "Impossible d'enregistrer la clé. Vérifiez qu'elle est correcte."
                showError = true
                isConnecting = false
                autoConnecting = false
                
                // Revenir au mode manuel
                withAnimation {
                    ryvieNotFound = true
                    showManualInput = true
                }
            }
        }
    }
    
    private func connectWithKey() {
        Task {
            await connectWithKeyAsync()
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct AnimatedGradientBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.36, green: 0.84, blue: 0.95),
                Color(red: 0.20, green: 0.60, blue: 0.80),
                Color(red: 0.30, green: 0.70, blue: 0.90)
            ]),
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                animateGradient = true
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(ViewModel())
}
