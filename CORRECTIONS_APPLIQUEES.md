# 🔧 Corrections Appliquées - NetBird iOS Extension

**Date**: 3 Décembre 2024  
**Problème**: Erreur `NEAgentErrorDomain Code=2` - "The VPN app used by the VPN configuration is not installed"

---

## 🐛 Diagnostic du Problème

L'analyse des logs système a révélé :
```
erreur	17:16:37.099948+0100	nesessionmanager	
ryvie.netbird.app[527]: Tearing down XPC connection due to setup error: 
Error Domain=NEAgentErrorDomain Code=2 "(null)"
```

### Causes Identifiées

1. **Incohérence des App Group Identifiers**
   - Mélange entre `group.io.netbird.app` et `group.ryvie.netbird.app`
   - L'app et l'extension ne pouvaient pas communiquer via le shared container

2. **Bundle ID de l'extension incorrect**
   - Code: `io.netbird.app.NetbirdNetworkExtension`
   - Attendu: `ryvie.netbird.app.NetbirdNetworkExtension`

---

## ✅ Corrections Appliquées

### 1. Uniformisation de l'App Group → `group.ryvie.netbird.app`

#### Fichier: `NetbirdKit/Preferences.swift`
```swift
// Ligne 18
let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.ryvie.netbird.app")

// Ligne 25
let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.ryvie.netbird.app")
```

#### Fichier: `NetbirdNetworkExtension/PacketTunnelProvider.swift`
```swift
// Ligne 307
let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.ryvie.netbird.app")
```

#### Fichier: `NetBird/Source/App/Views/AdvancedView.swift`
```swift
// Ligne 151 (fonction shareButtonTapped)
guard let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.ryvie.netbird.app") else {

// Ligne 198 (fonction saveLogFile)
guard let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.ryvie.netbird.app") else {
```

### 2. Correction du Bundle ID de l'Extension

#### Fichier: `NetbirdKit/NetworkExtensionAdapter.swift`
```swift
// Ligne 17
var extensionID = "ryvie.netbird.app.NetbirdNetworkExtension"
```

---

## 📋 Configuration Finale

### Bundle Identifiers
- **App principale**: `ryvie.netbird.app`
- **Network Extension**: `ryvie.netbird.app.NetbirdNetworkExtension`

### App Groups
- **Tous les composants**: `group.ryvie.netbird.app`

### Entitlements

**NetBird/NetBird.entitlements**:
```xml
<key>com.apple.developer.networking.networkextension</key>
<array>
    <string>packet-tunnel-provider</string>
</array>
<key>com.apple.security.application-groups</key>
<array>
    <string>group.ryvie.netbird.app</string>
</array>
```

**NetbirdNetworkExtension/NetbirdNetworkExtension.entitlements**:
```xml
<key>com.apple.developer.networking.networkextension</key>
<array>
    <string>packet-tunnel-provider</string>
</array>
<key>com.apple.security.application-groups</key>
<array>
    <string>group.ryvie.netbird.app</string>
</array>
```

---

## 🔍 Vérification

Un script de vérification automatique a été créé : `verify_config.sh`

```bash
./verify_config.sh
```

**Résultat** : ✅ Configuration Correcte - Aucune Erreur Détectée

---

## 🚀 Procédure de Déploiement

### 1. Nettoyage Complet
```bash
./clean_and_rebuild.sh
```

### 2. Dans Xcode

1. Ouvrir `NetBird.xcodeproj`
2. **Product > Clean Build Folder** (⇧⌘K)
3. Vérifier **Signing & Capabilities** pour les deux targets:
   
   **Target: NetBird**
   - Team: GW9M6A3925
   - Bundle ID: `ryvie.netbird.app`
   - App Groups: `group.ryvie.netbird.app` ✅
   - Network Extensions ✅
   
   **Target: NetbirdNetworkExtension**
   - Team: GW9M6A3925
   - Bundle ID: `ryvie.netbird.app.NetbirdNetworkExtension`
   - App Groups: `group.ryvie.netbird.app` ✅
   - Network Extensions > Packet Tunnel Provider ✅

4. **Product > Build** (⌘B)

### 3. Sur l'Appareil iOS

**IMPORTANT** : Nettoyage complet nécessaire

1. **Désinstaller** l'app NetBird existante
2. Aller dans **Réglages > Général > VPN et Gestion des appareils**
3. **Supprimer** toutes les configurations "NetBird Network Extension"
4. **Redémarrer** l'appareil (recommandé)
5. **Installer** la nouvelle version depuis Xcode
6. **Tester** la connexion

### 4. Vérification des Logs

```bash
# Logs Network Extension Manager
log stream --predicate 'process == "nesessionmanager"' --level debug

# Logs de l'app
log stream --predicate 'process == "NetBird"' --level debug
```

**Logs attendus** (succès) :
```
NESMVPNSession[...]: Entering state NESMVPNSessionStateConnecting
NEVPNTunnelPlugin(ryvie.netbird.app[...]): Sending start command
ryvie.netbird.app[...]: starting
ryvie.netbird.app[...]: XPC connection established
```

**Logs à éviter** (erreur) :
```
❌ Error Domain=NEAgentErrorDomain Code=2
❌ The VPN app used by the VPN configuration is not installed
❌ Tearing down XPC connection due to setup error
```

---

## 📊 Impact des Changements

### Fichiers Modifiés
- ✅ `NetbirdKit/NetworkExtensionAdapter.swift`
- ✅ `NetbirdKit/Preferences.swift`
- ✅ `NetbirdNetworkExtension/PacketTunnelProvider.swift`
- ✅ `NetBird/Source/App/Views/AdvancedView.swift`

### Fichiers Vérifiés (Déjà Corrects)
- ✅ `NetBird/NetBird.entitlements`
- ✅ `NetbirdNetworkExtension/NetbirdNetworkExtension.entitlements`
- ✅ `NetbirdNetworkExtension/Info.plist`
- ✅ `NetBird.xcodeproj/project.pbxproj`

### Nouveaux Fichiers Créés
- 📄 `verify_config.sh` - Script de vérification automatique
- 📄 `clean_and_rebuild.sh` - Script de nettoyage
- 📄 `VERIFICATION_CHECKLIST.md` - Checklist détaillée
- 📄 `CORRECTIONS_APPLIQUEES.md` - Ce document

---

## ✅ Critères de Succès

- [x] Aucune référence à `io.netbird.app` dans le code
- [x] Tous les App Groups utilisent `group.ryvie.netbird.app`
- [x] Bundle ID de l'extension correct
- [x] Entitlements synchronisés
- [x] Script de vérification passe sans erreur

### Tests à Effectuer

- [ ] L'app se lance sans crash
- [ ] Le bouton de connexion est actif
- [ ] La connexion démarre sans erreur NEAgentErrorDomain
- [ ] L'extension démarre (visible dans les logs)
- [ ] Le statut passe à "Connecting" puis "Connected"
- [ ] Les logs partagés sont accessibles
- [ ] La déconnexion fonctionne correctement

---

## 🆘 Support

Si le problème persiste après ces corrections :

1. Vérifier que le **Developer Certificate** est valide
2. Vérifier que le **Provisioning Profile** inclut l'App Group `group.ryvie.netbird.app`
3. Vérifier que l'appareil est en **mode développeur**
4. Essayer sur un **autre appareil** ou le **simulateur**
5. Consulter les logs système détaillés
6. Vérifier les **capabilities** dans le portail développeur Apple

---

## 📚 Références

- [Apple Developer - Network Extension](https://developer.apple.com/documentation/networkextension)
- [Apple Developer - App Groups](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_security_application-groups)
- [Debugging Network Extensions](https://developer.apple.com/documentation/networkextension/debugging_your_network_extension)

---

**Note**: Ces corrections garantissent la cohérence de la configuration entre tous les composants de l'app. Une clean install est **obligatoire** pour que les changements prennent effet.
