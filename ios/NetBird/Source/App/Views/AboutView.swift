//
//  AboutView.swift
//  Ryvie Connect
//
//  Created by Pascal Fischer on 12.10.23.
//

import SwiftUI

struct AboutView: View {
    
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
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
                VStack(spacing: 32) {
                    // Header avec logo
                    VStack(spacing: 20) {
                        Image("logo-onboarding")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .padding(.top, 40)
                        
                        Text("Ryvie Connect")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("Votre réseau privé sécurisé")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    
                    // Carte d'informations
                    VStack(spacing: 20) {
                        // Version
                        InfoCard(
                            icon: "info.circle.fill",
                            iconColor: Color(red: 0.36, green: 0.84, blue: 0.95),
                            title: "Version",
                            value: getAppVersion()
                        )
                        
                        // Build
                        InfoCard(
                            icon: "hammer.fill",
                            iconColor: Color(red: 0.95, green: 0.70, blue: 0.30),
                            title: "Build",
                            value: getBuildNumber()
                        )
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // Footer
                    VStack(spacing: 12) {
                        Text("© 2024 Ryvie")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Text("Tous droits réservés")
                            .font(.system(size: 13))
                            .foregroundColor(.gray.opacity(0.7))
                    }
                    .padding(.bottom, 40)
                }
            }
            
            if viewModel.showBetaProgramAlert {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismissBetaProgramAlert()
                    }
                
                BetaProgramAlert(viewModel: viewModel, isPresented: $viewModel.showBetaProgramAlert)
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
    }
    
    private func getAppVersion() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    }
    
    private func getBuildNumber() -> String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
    }
    
    private func dismissBetaProgramAlert() {
        viewModel.buttonLock = true
        viewModel.showBetaProgramAlert = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            viewModel.buttonLock = false
        }
    }
}

struct BetaProgramAlert: View {
    @StateObject var viewModel: ViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image("exclamation-circle")
                .padding(.top, 20)
            Text("Joining TestFlight Beta")
                .font(.title)
                .foregroundColor(Color("TextAlert"))
            Text("By signing up for the TestFlight you will be receiving the new updates early and can give us valuable feedback before the official release.")
                .foregroundColor(Color("TextAlert"))
                .multilineTextAlignment(.center)
            SolidButton(text: "Sign Up") {
                if let url = URL(string: "https://testflight.apple.com/join/jISzXOP8") {
                    UIApplication.shared.open(url)
                }
                isPresented.toggle()
            }
            Button {
                isPresented.toggle()
            } label: {
                Text("Cancel")
                    .font(.headline)
                    .foregroundColor(Color.accentColor)
                    .padding()
                    .frame(maxWidth: .infinity) // Span the whole width
                    .background(
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(red: 0, green: 0, blue: 0, opacity: 0))
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(Color.accentColor, lineWidth: 1)
                            )
                    )
            }
        }
        .padding()
        .background(Color("BgSideDrawer"))
        .cornerRadius(15)
        .shadow(radius: 10)
    }
}

struct InfoCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Icône
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            // Texte
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
