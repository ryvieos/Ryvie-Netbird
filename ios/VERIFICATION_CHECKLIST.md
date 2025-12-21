# ✅ Checklist de Vérification NetBird iOS

## 🔧 Corrections Appliquées

### 1. App Group Identifier
- ✅ **Uniformisé à**: `group.ryvie.netbird.app`
- ✅ Fichiers modifiés:
  - `NetbirdNetworkExtension/PacketTunnelProvider.swift` (ligne 307)
  - `NetBird/Source/App/Views/AdvancedView.swift` (lignes 151, 198)
  - `NetbirdKit/Preferences.swift` (lignes 18, 25)

### 2. Bundle Identifiers
- ✅ **App principale**: `ryvie.netbird.app`
- ✅ **Network Extension**: `ryvie.netbird.app.NetbirdNetworkExtension`
- ✅ Fichier modifié:
  - `NetbirdKit/NetworkExtensionAdapter.swift` (ligne 17)

### 3. Entitlements
- ✅ `NetBird/NetBird.entitlements`: `group.ryvie.netbird.app`
- ✅ `NetbirdNetworkExtension/NetbirdNetworkExtension.entitlements`: `group.ryvie.netbird.app`

---

## 📋 Vérifications à Faire dans Xcode

### Target: NetBird (App Principale)

1. **Signing & Capabilities**
   - [ ] Team: GW9M6A3925
   - [ ] Bundle Identifier: `ryvie.netbird.app`
   - [ ] App Groups capability présente
   - [ ] App Group: `group.ryvie.netbird.app` ✅ coché
   - [ ] Network Extensions capability présente

2. **Build Settings**
   - [ ] Code Signing Entitlements: `NetBird/NetBird.entitlements`
   - [ ] Product Bundle Identifier: `ryvie.netbird.app`

### Target: NetbirdNetworkExtension

1. **Signing & Capabilities**
   - [ ] Team: GW9M6A3925
   - [ ] Bundle Identifier: `ryvie.netbird.app.NetbirdNetworkExtension`
   - [ ] App Groups capability présente
   - [ ] App Group: `group.ryvie.netbird.app` ✅ coché
   - [ ] Network Extensions capability présente
   - [ ] Packet Tunnel Provider ✅ coché

2. **Build Settings**
   - [ ] Code Signing Entitlements: `NetbirdNetworkExtension/NetbirdNetworkExtension.entitlements`
   - [ ] Product Bundle Identifier: `ryvie.netbird.app.NetbirdNetworkExtension`

---

## 🚀 Procédure de Build et Test

### Étape 1: Nettoyage
```bash
cd /Users/jules/Desktop/ios-client
./clean_and_rebuild.sh
```

### Étape 2: Dans Xcode
1. Ouvrir `NetBird.xcodeproj`
2. Product > Clean Build Folder (⇧⌘K)
3. Vérifier les points ci-dessus
4. Product > Build (⌘B)

### Étape 3: Sur l'appareil iOS
1. **Désinstaller complètement** l'app NetBird existante
2. Aller dans Réglages > Général > VPN et Gestion des appareils
3. Supprimer toutes les configurations VPN "NetBird Network Extension"
4. Redémarrer l'appareil (recommandé)

### Étape 4: Installation et Test
1. Installer la nouvelle version depuis Xcode
2. Lancer l'app
3. Tenter de se connecter
4. Vérifier les logs:
   ```bash
   log stream --predicate 'process == "nesessionmanager"' --level debug
   ```

---

## 🐛 Diagnostic des Erreurs

### Erreur: "NEAgentErrorDomain Code=2"
**Cause**: L'extension n'est pas trouvée ou mal configurée
**Solutions**:
- ✅ Bundle ID de l'extension correct
- ✅ Extension incluse dans l'app bundle
- ✅ Entitlements corrects

### Erreur: "The VPN app used by the VPN configuration is not installed"
**Cause**: Configuration VPN obsolète ou Bundle ID incorrect
**Solutions**:
- ✅ Supprimer les anciennes configurations VPN
- ✅ Désinstaller et réinstaller l'app
- ✅ Vérifier que le Bundle ID correspond

### Erreur: "XPC connection went away"
**Cause**: L'extension crash au démarrage
**Solutions**:
- Vérifier les logs de l'extension
- Vérifier l'accès à l'App Group
- Vérifier les permissions

---

## 🔍 Commandes de Diagnostic

### Logs système
```bash
# Logs Network Extension Manager
log stream --predicate 'process == "nesessionmanager"' --level debug

# Logs de l'app NetBird
log stream --predicate 'process == "NetBird"' --level debug

# Tous les logs NetBird
log stream --predicate 'processImagePath CONTAINS "netbird"' --level debug
```

### Vérifier les configurations VPN
```bash
# Lister les configurations VPN
scutil --nc list
```

### Vérifier l'App Group
```bash
# Sur le simulateur
ls -la ~/Library/Developer/CoreSimulator/Devices/*/data/Containers/Shared/AppGroup/
```

---

## ✅ Critères de Succès

- [ ] L'app se lance sans crash
- [ ] Le bouton de connexion est actif
- [ ] La connexion démarre sans erreur NEAgentErrorDomain
- [ ] L'extension Network Extension démarre (visible dans les logs)
- [ ] Le statut passe à "Connecting" puis "Connected"
- [ ] Les logs ne montrent pas "The VPN app used by the VPN configuration is not installed"

---

## 📝 Notes Importantes

1. **App Group**: Tous les fichiers partagés (config, logs, state) utilisent maintenant `group.ryvie.netbird.app`
2. **Bundle IDs**: Cohérents entre le code et Xcode
3. **Entitlements**: Synchronisés avec les capabilities Xcode
4. **Clean Install**: Toujours désinstaller l'ancienne version avant de tester

---

## 🆘 Si Ça Ne Marche Toujours Pas

1. Vérifier que le Developer Certificate est valide
2. Vérifier que le Provisioning Profile inclut l'App Group
3. Vérifier que l'appareil est en mode développeur
4. Essayer sur un autre appareil ou le simulateur
5. Vérifier les logs système pour des erreurs spécifiques
