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
    
    var body: some View {
        ZStack {
            Color("BgPage")
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Register with Setup Key")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color("TextPrimary"))
                        .padding(.top, UIScreen.main.bounds.height * 0.04)
                    
                    Text("Enter your setup key to register this device with your NetBird network.")
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
                    
                    SolidButton(text: isVerifying ? "Registering..." : "Register Device") {
                        registerWithSetupKey()
                    }
                    .disabled(setupKey.isEmpty || !viewModel.isValidSetupKey(setupKey) || isVerifying)
                    .padding(.top, 10)
                    
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
    }
    
    private func registerWithSetupKey() {
        guard !setupKey.isEmpty && viewModel.isValidSetupKey(setupKey) else {
            print("❌ [SetupKeyView] Invalid setup key format")
            return
        }
        
        print("🔑 [SetupKeyView] Starting registration with setup key")
        isVerifying = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Configurer le serveur par défaut
            let serverURL = "https://netbird.ryvie.fr"
            print("🌐 [SetupKeyView] Configuring server URL: \(serverURL)")
            let ssoSupported = viewModel.updateManagementURL(url: serverURL)
            
            if ssoSupported == nil {
                print("❌ [SetupKeyView] Failed to connect to server")
                errorMessage = "Failed to connect to server. Please check your internet connection."
                showErrorAlert = true
                isVerifying = false
                return
            }
            
            print("✅ [SetupKeyView] Server configured successfully, SSO supported: \(ssoSupported ?? false)")
            
            // Enregistrer avec la setup key
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                do {
                    print("📝 [SetupKeyView] Calling setSetupKey...")
                    try viewModel.setSetupKey(key: setupKey)
                    print("✅ [SetupKeyView] Device registered successfully!")
                    
                    // Succès !
                    setupKey = ""
                    isVerifying = false
                    
                    // Fermer le menu latéral et retourner à l'écran principal
                    print("🔙 [SetupKeyView] Closing menu and returning to main screen")
                    presentationMode.wrappedValue.dismiss()
                    viewModel.presentSideDrawer = false
                    
                    // Attendre que la configuration soit bien enregistrée
                    print("⏳ [SetupKeyView] Waiting 1 second for configuration to be saved...")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        print("🔍 [SetupKeyView] Current extension state: \(viewModel.extensionState)")
                        
                        // Déconnecter si déjà connecté
                        if viewModel.extensionState != .disconnected {
                            print("🔌 [SetupKeyView] Extension is connected, disconnecting first...")
                            viewModel.close()
                            
                            // Attendre que la déconnexion soit terminée (3 secondes)
                            print("⏳ [SetupKeyView] Waiting 3 seconds for disconnection...")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                print("🔍 [SetupKeyView] Checking extension state after disconnect...")
                                viewModel.checkExtensionState()
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    print("🚀 [SetupKeyView] Attempting to connect...")
                                    viewModel.connect()
                                    print("✅ [SetupKeyView] Connect() called successfully")
                                }
                            }
                        } else {
                            print("🔍 [SetupKeyView] Extension is disconnected, checking state...")
                            viewModel.checkExtensionState()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                print("🚀 [SetupKeyView] Attempting to connect...")
                                viewModel.connect()
                                print("✅ [SetupKeyView] Connect() called successfully")
                            }
                        }
                    }
                    
                } catch {
                    print("❌ [SetupKeyView] Registration failed: \(error.localizedDescription)")
                    errorMessage = "Failed to register with setup key. Please verify your key is correct and try again."
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
