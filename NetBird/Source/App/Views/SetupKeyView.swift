//
//  SetupKeyView.swift
//  NetBird
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
    
    var body: some View {
        ZStack {
            Color("BgPage")
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Setup Key Management")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color("TextPrimary"))
                        .padding(.top, UIScreen.main.bounds.height * 0.04)
                    
                    if hasExistingKey {
                        Text("A setup key is currently configured. You can remove it to enter a new one.")
                            .multilineTextAlignment(.leading)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color("TextSecondary"))
                            .fixedSize(horizontal: false, vertical: true)
                        
                        SolidButton(text: "Remove Setup Key") {
                            removeSetupKey()
                        }
                        .padding(.top, 10)
                    } else {
                        Text("Enter your setup key to connect to your Ryvie network.")
                            .multilineTextAlignment(.leading)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color("TextSecondary"))
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("Setup Key")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color("TextPrimary"))
                            .padding(.top, 10)
                        
                        CustomTextField(
                            placeholder: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
                            text: $setupKey,
                            secure: .constant(false)
                        )
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        
                        if !setupKey.isEmpty && !viewModel.isValidSetupKey(setupKey) {
                            Text("Invalid setup key format")
                                .foregroundColor(.red)
                                .font(.system(size: 14))
                        }
                        
                        SolidButton(text: isVerifying ? "Saving..." : "Save Key") {
                            saveSetupKey()
                        }
                        .disabled(setupKey.isEmpty || !viewModel.isValidSetupKey(setupKey) || isVerifying)
                        .padding(.top, 10)
                    }
                    
                    Spacer()
                }
                .padding([.leading, .trailing], UIScreen.main.bounds.width * 0.10)
            }
            .ignoresSafeArea(.keyboard)
            
            if showErrorAlert {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showErrorAlert = false
                    }
                
                ErrorAlert(
                    isPresented: $showErrorAlert,
                    errorMessage: errorMessage
                )
                .frame(maxWidth: UIScreen.main.bounds.width * 0.9)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: CustomBackButton(text: "Setup Key") {
            presentationMode.wrappedValue.dismiss()
        })
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onAppear {
            checkForExistingKey()
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

struct ErrorAlert: View {
    @Binding var isPresented: Bool
    var errorMessage: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image("exclamation-circle")
                .padding(.top, 20)
            Text("Registration Failed")
                .font(.title)
                .foregroundColor(Color("TextAlert"))
            Text(errorMessage)
                .foregroundColor(Color("TextAlert"))
                .multilineTextAlignment(.center)
            SolidButton(text: "Ok") {
                isPresented = false
            }
            .padding(.top, 20)
        }
        .padding()
        .background(Color("BgSideDrawer"))
        .cornerRadius(15)
        .shadow(radius: 10)
    }
}

#Preview {
    SetupKeyView()
        .environmentObject(ViewModel())
}
