//
//  SetupKeyView.swift
//  Ryvie Connect
//
//  Created by Cascade on 03.12.24.
//

import SwiftUI

struct SetupKeyView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var setupKey: String = ""
    @State private var isVerifying = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var hasExistingKey = false
    @State private var showDeleteKeyAlert = false
    
    var body: some View {
        ZStack {
            // Background gradient moderne
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.97, blue: 0.99),
                    Color(red: 0.90, green: 0.94, blue: 0.98)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header avec icône
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.36, green: 0.84, blue: 0.95),
                                            Color(red: 0.20, green: 0.60, blue: 0.80)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .shadow(color: Color(red: 0.36, green: 0.84, blue: 0.95).opacity(0.3), radius: 15, x: 0, y: 8)
                            
                            Image(systemName: "key.fill")
                                .font(.system(size: 36, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 40)
                        
                        Text("Clé de connexion")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text(hasExistingKey ? "Gérer votre clé Ryvie" : "Connectez-vous à votre réseau")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 30)
                    
                    // Contenu principal
                    VStack(spacing: 20) {
                        if hasExistingKey {
                            // Carte d'état connecté
                            VStack(spacing: 16) {
                                HStack(spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color(red: 0.30, green: 0.85, blue: 0.40))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("État de la connexion")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.gray)
                                        
                                        Text("Clé configurée")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.black)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(20)
                                .background(Color(red: 0.30, green: 0.85, blue: 0.40).opacity(0.1))
                                .cornerRadius(16)
                                
                                Text("Une clé de connexion est actuellement configurée. Vous pouvez la supprimer pour en configurer une nouvelle.")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 8)
                                
                                // Bouton supprimer
                                Button(action: {
                                    showDeleteKeyAlert = true
                                }) {
                                    HStack(spacing: 10) {
                                        Image(systemName: "trash.fill")
                                            .font(.system(size: 16, weight: .semibold))
                                        
                                        Text("Supprimer la clé")
                                            .font(.system(size: 17, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.95, green: 0.55, blue: 0.25),
                                                Color(red: 0.95, green: 0.40, blue: 0.20)
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(14)
                                    .shadow(color: Color(red: 0.95, green: 0.55, blue: 0.25).opacity(0.4), radius: 12, x: 0, y: 6)
                                }
                                .padding(.top, 8)
                            }
                            .padding(24)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
                        } else {
                            // Formulaire de saisie
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Entrez votre clé")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.black)
                                    
                                    Text("Format: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX")
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray)
                                }
                                
                                // Champ de texte moderne
                                VStack(alignment: .leading, spacing: 8) {
                                    TextField("Clé de connexion", text: $setupKey)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.black)
                                        .padding(16)
                                        .background(Color(red: 0.96, green: 0.97, blue: 0.98))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(
                                                    !setupKey.isEmpty && !viewModel.isValidSetupKey(setupKey) 
                                                        ? Color.red.opacity(0.5)
                                                        : Color.clear,
                                                    lineWidth: 2
                                                )
                                        )
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                    
                                    if !setupKey.isEmpty && !viewModel.isValidSetupKey(setupKey) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "exclamationmark.circle.fill")
                                                .font(.system(size: 12))
                                            Text("Format de clé invalide")
                                                .font(.system(size: 13, weight: .medium))
                                        }
                                        .foregroundColor(.red)
                                    }
                                }
                                
                                // Bouton sauvegarder
                                Button(action: {
                                    saveSetupKey()
                                }) {
                                    HStack(spacing: 10) {
                                        if isVerifying {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .scaleEffect(0.9)
                                        } else {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 18, weight: .semibold))
                                        }
                                        
                                        Text(isVerifying ? "Enregistrement..." : "Enregistrer")
                                            .font(.system(size: 17, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.36, green: 0.84, blue: 0.95),
                                                Color(red: 0.20, green: 0.60, blue: 0.80)
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(14)
                                    .shadow(color: Color(red: 0.36, green: 0.84, blue: 0.95).opacity(0.4), radius: 12, x: 0, y: 6)
                                    .opacity((setupKey.isEmpty || !viewModel.isValidSetupKey(setupKey) || isVerifying) ? 0.5 : 1.0)
                                }
                                .disabled(setupKey.isEmpty || !viewModel.isValidSetupKey(setupKey) || isVerifying)
                                .padding(.top, 8)
                            }
                            .padding(24)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer(minLength: 40)
                }
            }
            .ignoresSafeArea(.keyboard)
            
            // Alerte d'erreur moderne
            if showErrorAlert {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showErrorAlert = false
                    }
                
                ModernErrorAlert(
                    isPresented: $showErrorAlert,
                    errorMessage: errorMessage
                )
                .padding(.horizontal, 30)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Retour")
                            .font(.system(size: 17))
                    }
                    .foregroundColor(Color(red: 0.36, green: 0.84, blue: 0.95))
                }
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onAppear {
            checkForExistingKey()
        }
        .alert(isPresented: $showDeleteKeyAlert) {
            Alert(
                title: Text("⚠️ Supprimer la clé ?"),
                message: Text("Cette action va supprimer votre clé de connexion. Pour vous reconnecter, vous devrez :\n\n• Être sur le même réseau que votre Ryvie\n• Ou avoir votre clé de connexion"),
                primaryButton: .destructive(Text("Supprimer")) {
                    removeSetupKey()
                },
                secondaryButton: .cancel(Text("Annuler"))
            )
        }
    }
    
    private func checkForExistingKey() {
        // Vérifier si une configuration existe déjà
        // Si statusDetailsValid est true, cela signifie qu'une clé est configurée
        hasExistingKey = viewModel.statusDetailsValid
    }
    
    private func removeSetupKey() {
        print("🗑️ [SetupKeyView] Removing setup key")
        
        // Déconnecter d'abord si connecté
        if viewModel.extensionState != .disconnected {
            viewModel.close()
        }
        
        // Effacer la configuration
        viewModel.clearDetails()
        
        // Mettre à jour l'état
        hasExistingKey = false
        
        print("✅ [SetupKeyView] Setup key removed successfully")
    }
    
    private func saveSetupKey() {
        guard !setupKey.isEmpty && viewModel.isValidSetupKey(setupKey) else {
            print("❌ [SetupKeyView] Invalid setup key format")
            return
        }
        
        print("🔑 [SetupKeyView] Saving setup key")
        isVerifying = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Configurer le serveur par défaut
            let serverURL = "https://netbird.ryvie.fr"
            print("🌐 [SetupKeyView] Configuring server URL: \(serverURL)")
            let ssoSupported = viewModel.updateManagementURL(url: serverURL)
            
            if ssoSupported == nil {
                print("❌ [SetupKeyView] Failed to connect to server")
                errorMessage = "Impossible de se connecter au serveur. Vérifiez votre connexion internet."
                showErrorAlert = true
                isVerifying = false
                return
            }
            
            print("✅ [SetupKeyView] Server configured successfully")
            
            // Enregistrer la setup key
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                do {
                    print("📝 [SetupKeyView] Saving setup key...")
                    try viewModel.setSetupKey(key: setupKey)
                    print("✅ [SetupKeyView] Setup key saved successfully!")
                    
                    // Succès !
                    setupKey = ""
                    isVerifying = false
                    hasExistingKey = true
                    
                    // Fermer le menu
                    print("🔙 [SetupKeyView] Closing menu")
                    presentationMode.wrappedValue.dismiss()
                    
                } catch {
                    print("❌ [SetupKeyView] Failed to save setup key: \(error.localizedDescription)")
                    errorMessage = "Impossible d'enregistrer la clé. Vérifiez qu'elle est correcte."
                    showErrorAlert = true
                    isVerifying = false
                }
            }
        }
    }
}

struct ModernErrorAlert: View {
    @Binding var isPresented: Bool
    var errorMessage: String
    
    var body: some View {
        VStack(spacing: 24) {
            // Icône d'erreur
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.15))
                    .frame(width: 70, height: 70)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.red)
            }
            .padding(.top, 8)
            
            VStack(spacing: 12) {
                Text("⚠️ Erreur")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                
                Text(errorMessage)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Bouton OK
            Button(action: {
                isPresented = false
            }) {
                Text("Compris")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.red,
                                Color.red.opacity(0.8)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                    .shadow(color: Color.red.opacity(0.4), radius: 12, x: 0, y: 6)
            }
            .padding(.top, 8)
        }
        .padding(28)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.2), radius: 30, x: 0, y: 15)
    }
}

#Preview {
    SetupKeyView()
        .environmentObject(ViewModel())
}
