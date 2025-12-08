//
//  ModernConnectButton.swift
//  Ryvie Connect
//
//  Created on 05.12.24.
//

import SwiftUI

struct ModernConnectButton: View {
    @Binding var isConnected: Bool
    @Binding var isConnecting: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var pulseAnimation = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
            action()
        }) {
            ZStack {
                // Pulse effect for connected state
                if isConnected && !isConnecting {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: gradientColors),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 200, height: 200)
                        .opacity(pulseAnimation ? 0 : 0.4)
                        .scaleEffect(pulseAnimation ? 1.3 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 2)
                                .repeatForever(autoreverses: false),
                            value: pulseAnimation
                        )
                }
                
                // Background circle with glow
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: gradientColors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 180, height: 180)
                    .shadow(color: shadowColor, radius: isPressed ? 10 : 25, x: 0, y: isPressed ? 5 : 15)
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                
                // Animated ring for connecting state
                if isConnecting {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 3)
                        .frame(width: 160, height: 160)
                    
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.white, .white.opacity(0.1)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 160, height: 160)
                        .rotationEffect(Angle(degrees: isConnecting ? 360 : 0))
                        .animation(
                            Animation.linear(duration: 1.5)
                                .repeatForever(autoreverses: false),
                            value: isConnecting
                        )
                }
                
                // Inner circle with glassmorphism
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 150, height: 150)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                
                // Icon or animation
                if isConnecting {
                    VStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        
                        Text("Connexion...")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: iconName)
                            .font(.system(size: 55, weight: .thin))
                            .foregroundColor(.white)
                            .scaleEffect(isConnected ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isConnected)
                        
                        Text(statusText)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .tracking(0.5)
                    }
                    .scaleEffect(isPressed ? 0.9 : 1.0)
                }
            }
        }
        .disabled(isConnecting)
        .onAppear {
            if isConnected {
                pulseAnimation = true
            }
        }
        .onChange(of: isConnected) { newValue in
            pulseAnimation = newValue
        }
    }
    
    private var gradientColors: [Color] {
        if isConnecting {
            return [
                Color(red: 0.95, green: 0.70, blue: 0.30),
                Color(red: 0.95, green: 0.50, blue: 0.20)
            ]
        } else if isConnected {
            return [
                Color(red: 0.30, green: 0.85, blue: 0.40),
                Color(red: 0.20, green: 0.70, blue: 0.30)
            ]
        } else {
            return [
                Color(red: 0.36, green: 0.84, blue: 0.95),
                Color(red: 0.20, green: 0.60, blue: 0.80)
            ]
        }
    }
    
    private var shadowColor: Color {
        if isConnected {
            return Color(red: 0.30, green: 0.85, blue: 0.40).opacity(0.5)
        } else {
            return Color(red: 0.36, green: 0.84, blue: 0.95).opacity(0.5)
        }
    }
    
    private var iconName: String {
        isConnected ? "checkmark.shield.fill" : "power"
    }
    
    private var statusText: String {
        if isConnecting {
            return "Connexion..."
        } else if isConnected {
            return "Connecté"
        } else {
            return "Se connecter"
        }
    }
}

#Preview {
    VStack(spacing: 50) {
        ModernConnectButton(
            isConnected: .constant(false),
            isConnecting: .constant(false),
            action: {}
        )
        
        ModernConnectButton(
            isConnected: .constant(false),
            isConnecting: .constant(true),
            action: {}
        )
        
        ModernConnectButton(
            isConnected: .constant(true),
            isConnecting: .constant(false),
            action: {}
        )
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
