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
                
                // Setup Key Input
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
        }
    }
    
    private func connectWithKey() {
        isConnecting = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let serverURL = "https://netbird.ryvie.fr"
            let ssoSupported = viewModel.updateManagementURL(url: serverURL)
            
            if ssoSupported == nil {
                errorMessage = "Impossible de se connecter au serveur. Vérifiez votre connexion internet."
                showError = true
                isConnecting = false
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                do {
                    try viewModel.setSetupKey(key: setupKey)
                    
                    // Clé enregistrée avec succès - ne pas se connecter automatiquement
                    // L'utilisateur devra cliquer sur le bouton de connexion
                    isConnecting = false
                    setupKey = ""
                    
                    print("✅ [OnboardingView] Setup key saved successfully")
                    
                } catch {
                    errorMessage = "Clé de configuration invalide. Veuillez vérifier et réessayer."
                    showError = true
                    isConnecting = false
                }
            }
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
