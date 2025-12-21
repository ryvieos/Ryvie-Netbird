# 🚀 Ryvie NetBird iOS - Guide de Démarrage

Fork personnalisé du client iOS NetBird avec corrections et améliorations.

---

## 📋 Prérequis

- **macOS** avec Xcode 14.0+
- **iOS 14.0+** (appareil physique requis, le simulateur ne supporte pas les Network Extensions)
- **Apple Developer Account** avec accès aux capabilities Network Extension
- **gomobile** installé
- Accès au repo principal NetBird (pour compiler le SDK)

---

## 🔧 Installation et Configuration

### 1. Cloner les Repositories

```bash
# Clone le repo principal NetBird (pour le SDK)
git clone https://github.com/netbirdio/netbird.git

# Clone ce fork Ryvie
git clone https://github.com/ryvieos/Ryvie-Netbird.git
cd Ryvie-Netbird
```

### 2. Compiler le SDK NetBird

Le SDK Go doit être compilé en xcframework :

```bash
cd ../netbird

# Installer gomobile si pas déjà fait
go install golang.org/x/mobile/cmd/gomobile@latest
gomobile init

# Compiler le SDK pour iOS
gomobile bind -target=ios -bundleid=ryvie.netbird.framework -o ../Ryvie-Netbird/NetBirdSDK.xcframework ./client/ios/NetBirdSDK
```

Le fichier `NetBirdSDK.xcframework` doit être dans le dossier racine de `Ryvie-Netbird`.

### 3. Ouvrir le Projet dans Xcode

```bash
cd ../Ryvie-Netbird
open NetBird.xcodeproj
```

### 4. Configuration Xcode (IMPORTANT)

#### Target: **NetBird** (App Principale)

1. **Signing & Capabilities**
   - Team: Sélectionner votre équipe de développement
   - Bundle Identifier: `ryvie.netbird.app`
   - ✅ Vérifier que **App Groups** est activé
   - ✅ App Group: `group.ryvie.netbird.app` coché
   - ✅ Vérifier que **Network Extensions** est activé

#### Target: **NetbirdNetworkExtension**

1. **Signing & Capabilities**
   - Team: Même équipe que l'app principale
   - Bundle Identifier: `ryvie.netbird.app.NetbirdNetworkExtension`
   - ✅ Vérifier que **App Groups** est activé
   - ✅ App Group: `group.ryvie.netbird.app` coché
   - ✅ Vérifier que **Network Extensions** est activé
   - ✅ **Packet Tunnel Provider** coché

### 5. Vérification Automatique

Un script de vérification est fourni :

```bash
./verify_config.sh
```

Résultat attendu : ✅ **Configuration Correcte - Aucune Erreur Détectée**

---

## 🏗️ Build et Déploiement

### Build

1. Dans Xcode : **Product > Clean Build Folder** (⇧⌘K)
2. **Product > Build** (⌘B)

### Installation sur Appareil

1. Connecter un appareil iOS physique via câble
2. Sélectionner l'appareil comme destination
3. **Product > Run** (⌘R)

⚠️ **Important** : L'app ne peut **PAS** fonctionner sur le simulateur iOS (limitation des Network Extensions).

---

## 🔍 Structure du Projet

```
Ryvie-Netbird/
├── NetBird/                          # App principale (UI)
│   ├── Source/App/                   # Code Swift de l'app
│   │   ├── Views/                    # Vues SwiftUI
│   │   └── ViewModels/               # ViewModels
│   └── NetBird.entitlements          # Entitlements app
│
├── NetbirdNetworkExtension/          # Extension VPN
│   ├── PacketTunnelProvider.swift    # Provider principal
│   └── NetbirdNetworkExtension.entitlements
│
├── NetbirdKit/                       # Code partagé
│   ├── NetworkExtensionAdapter.swift # Pont UI ↔ Extension
│   ├── Preferences.swift             # Gestion config
│   └── StatusDetails.swift           # Modèles de données
│
├── NetBirdSDK.xcframework/           # SDK Go compilé (à générer)
│
└── Scripts de vérification
    ├── verify_config.sh              # Vérification config
    ├── clean_and_rebuild.sh          # Nettoyage projet
    └── VERIFICATION_CHECKLIST.md     # Checklist détaillée
```

---

## ✨ Corrections et Améliorations

Ce fork inclut les corrections suivantes par rapport au NetBird original :

### 1. **Configuration Unifiée**
- ✅ App Group uniformisé : `group.ryvie.netbird.app`
- ✅ Bundle IDs cohérents :
  - App : `ryvie.netbird.app`
  - Extension : `ryvie.netbird.app.NetbirdNetworkExtension`

### 2. **Améliorations UI**
- ✅ Filtre par défaut sur "Connected" uniquement
- ✅ Compteur affiche "X Peers connected" au lieu de "X of Y"

### 3. **Fichiers de Documentation**
- `CORRECTIONS_APPLIQUEES.md` - Détails des corrections
- `VERIFICATION_CHECKLIST.md` - Checklist complète
- `README_CORRECTIONS.md` - Résumé rapide

---

## 🐛 Troubleshooting

### Erreur: "NEAgentErrorDomain Code=2"

**Cause** : Configuration incorrecte de l'extension

**Solution** :
1. Exécuter `./verify_config.sh`
2. Vérifier les Signing & Capabilities dans Xcode
3. Clean Build Folder et rebuild

### Erreur: "The VPN app used by the VPN configuration is not installed"

**Cause** : Configuration VPN obsolète sur l'appareil

**Solution** :
1. Désinstaller complètement l'app
2. Réglages > Général > VPN → Supprimer les configs "NetBird"
3. Redémarrer l'appareil
4. Réinstaller l'app

### L'extension ne démarre pas

**Solution** :
1. Vérifier les logs système :
   ```bash
   log stream --predicate 'process == "nesessionmanager"' --level debug
   ```
2. Vérifier que l'App Group est bien configuré
3. Consulter `TROUBLESHOOTING.md`

---

## 📊 Logs et Diagnostic

### Logs Système

```bash
# Logs Network Extension Manager
log stream --predicate 'process == "nesessionmanager"' --level debug

# Logs de l'app NetBird
log stream --predicate 'process == "NetBird"' --level debug

# Tous les logs NetBird
log stream --predicate 'processImagePath CONTAINS "netbird"' --level debug
```

### Logs de l'App

Les logs sont stockés dans l'App Group et accessibles via l'app :
- Menu > Advanced > Share Logs

---

## 🔐 Sécurité et Permissions

### Capabilities Requises

**App Principale** :
- Network Extensions
- App Groups (`group.ryvie.netbird.app`)

**Network Extension** :
- Network Extensions (Packet Tunnel Provider)
- App Groups (`group.ryvie.netbird.app`)

### Provisioning Profile

Le Provisioning Profile doit inclure :
- Network Extension entitlement
- App Group `group.ryvie.netbird.app`

---

## 📚 Documentation Supplémentaire

- `VERIFICATION_CHECKLIST.md` - Checklist de vérification complète
- `CORRECTIONS_APPLIQUEES.md` - Documentation des corrections
- `DEPLOYMENT_GUIDE.md` - Guide de déploiement
- `TROUBLESHOOTING.md` - Guide de dépannage

---

## 🤝 Contribution

Ce projet est un fork de [NetBird iOS Client](https://github.com/netbirdio/ios-client).

### Workflow de Développement

1. Créer une branche pour vos modifications
2. Faire vos changements
3. Tester sur appareil physique
4. Créer une Pull Request

---

## 📄 Licence

Ce projet hérite de la licence du projet NetBird original (GPLv3).

---

## 🆘 Support

Pour les problèmes spécifiques à ce fork :
- Ouvrir une issue sur ce repository

Pour les questions générales NetBird :
- [Documentation NetBird](https://netbird.io/docs/)
- [Slack NetBird](https://join.slack.com/t/netbirdio/shared_invite/zt-vrahf41g-ik1v7fV8du6t0RwxSrJ96A)

---

## ✅ Checklist de Premier Lancement

- [ ] Cloner les deux repos (netbird + Ryvie-Netbird)
- [ ] Compiler le SDK avec gomobile
- [ ] Ouvrir le projet dans Xcode
- [ ] Configurer Signing & Capabilities pour les 2 targets
- [ ] Vérifier avec `./verify_config.sh`
- [ ] Clean Build Folder
- [ ] Build le projet
- [ ] Connecter un appareil iOS physique
- [ ] Installer et tester

**Bonne chance ! 🚀**
