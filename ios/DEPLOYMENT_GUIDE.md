# 📱 Guide de déploiement - NetBird iOS

## ✅ Configuration terminée

L'app est maintenant configurée pour ton compte développeur Apple et prête à être déployée sur un appareil physique.

## 🔧 Modifications effectuées

### 1. Bundle Identifiers
- **App principale** : `ryvie.netbird.app`
- **Extension réseau** : `ryvie.netbird.app.NetbirdNetworkExtension`
- **Development Team** : `GW9M6A3925`

### 2. App Group
- **ID** : `group.ryvie.netbird.app`
- Configuré dans :
  - `NetBird/NetBird.entitlements`
  - `NetbirdNetworkExtension/NetbirdNetworkExtension.entitlements`
  - `NetbirdKit/Preferences.swift`

### 3. Firebase supprimé
- Toutes les dépendances Firebase ont été retirées
- L'app est maintenant plus légère et plus simple

## 📱 Déploiement sur iPhone/iPad

### Prérequis
1. **iPhone ou iPad** connecté via USB
2. **Compte développeur Apple** configuré dans Xcode
3. **Appareil enregistré** dans ton compte développeur

### Étapes

#### 1. Connecter l'appareil
- Brancher l'iPhone/iPad via USB
- Déverrouiller l'appareil
- Faire confiance à l'ordinateur si demandé

#### 2. Sélectionner l'appareil dans Xcode
- **Product** → **Destination** → Sélectionner ton appareil
- Ou utiliser le menu déroulant en haut de Xcode

#### 3. Configurer la signature automatique
Dans Xcode :
1. Sélectionner le projet **NetBird** dans le navigateur
2. Sélectionner la target **NetBird**
3. Onglet **Signing & Capabilities**
4. Cocher **Automatically manage signing**
5. Sélectionner ton **Team** (GW9M6A3925)
6. Répéter pour la target **NetbirdNetworkExtension**

#### 4. Créer l'App Group dans le portail développeur

**Important** : L'App Group doit être créé dans ton compte Apple Developer.

1. Aller sur https://developer.apple.com/account
2. **Certificates, Identifiers & Profiles**
3. **Identifiers** → **App Groups**
4. Cliquer sur **+** pour créer un nouveau groupe
5. Entrer l'ID : `group.ryvie.netbird.app`
6. Enregistrer

#### 5. Associer l'App Group aux App IDs

Pour **ryvie.netbird.app** :
1. **Identifiers** → **App IDs**
2. Sélectionner `ryvie.netbird.app` (ou le créer)
3. **App Groups** → Cocher la case
4. **Edit** → Sélectionner `group.ryvie.netbird.app`
5. **Save**

Pour **ryvie.netbird.app.NetbirdNetworkExtension** :
1. Même procédure
2. Sélectionner `ryvie.netbird.app.NetbirdNetworkExtension`
3. Associer au même App Group

#### 6. Compiler et déployer
Dans Xcode :
- **Product** → **Run** (Cmd+R)
- Ou cliquer sur le bouton ▶️

#### 7. Autoriser l'app sur l'appareil
Sur l'iPhone/iPad :
1. **Réglages** → **Général** → **VPN et gestion des appareils**
2. Sous "App développeur", cliquer sur ton compte
3. **Faire confiance à [ton compte]**

#### 8. Lancer l'app
- L'app devrait se lancer automatiquement
- Sinon, la lancer depuis l'écran d'accueil

## 🔑 Tester la fonctionnalité Setup Key

### 1. Obtenir une setup key
1. Se connecter au dashboard NetBird : https://netbird.ryvie.fr
2. **Settings** → **Setup Keys**
3. Créer ou copier une setup key existante

### 2. Enregistrer l'appareil
1. Ouvrir l'app NetBird
2. **Menu ☰** → **Setup Key**
3. Entrer la setup key
4. Cliquer **Register Device**

### 3. Connexion automatique
L'app devrait :
- ✅ Enregistrer l'appareil
- ✅ Fermer le menu
- ✅ Se connecter automatiquement au VPN

### 4. Vérifier
- Dans l'app : État devrait être "Connected"
- Dans le dashboard : L'appareil devrait apparaître comme "Connected"

## 🐛 Dépannage

### Erreur : "App Group not found"
**Cause** : L'App Group n'est pas créé dans le portail développeur.
**Solution** : Suivre l'étape 4 ci-dessus.

### Erreur : "Failed to install"
**Cause** : Problème de signature ou de provisioning.
**Solution** :
1. Vérifier que le Team est correct
2. Vérifier que l'appareil est enregistré
3. Nettoyer le build : **Product** → **Clean Build Folder** (Cmd+Shift+K)
4. Réessayer

### Erreur : "Untrusted Developer"
**Cause** : L'app n'est pas autorisée sur l'appareil.
**Solution** : Suivre l'étape 7 ci-dessus.

### L'app se lance mais crash immédiatement
**Cause** : Problème d'App Group.
**Solution** :
1. Vérifier que l'App Group est créé
2. Vérifier qu'il est associé aux deux App IDs
3. Désinstaller l'app de l'appareil
4. Réinstaller depuis Xcode

### La connexion VPN ne fonctionne pas
**Cause** : Extension VPN non autorisée.
**Solution** :
1. **Réglages** → **Général** → **VPN et gestion des appareils**
2. Vérifier que **NetBird** apparaît dans la liste VPN
3. Si absent, réinstaller l'app

## 📊 Logs de debug

Pour voir les logs détaillés :
1. Dans Xcode, ouvrir la console : **Cmd+Shift+Y**
2. Filtrer sur `[SetupKeyView]`, `[ViewModel]` ou `[NetworkExtensionAdapter]`
3. Chercher les emojis :
   - 🔑 = Enregistrement
   - 🚀 = Connexion
   - ✅ = Succès
   - ❌ = Erreur

## 🎯 Checklist finale

Avant de tester :
- [ ] Appareil connecté via USB
- [ ] Team configuré dans Xcode
- [ ] App Group créé dans le portail développeur
- [ ] App Group associé aux deux App IDs
- [ ] Build réussi
- [ ] App installée sur l'appareil
- [ ] App autorisée dans les réglages
- [ ] Setup key disponible

## 🚀 Prochaines étapes

Une fois que tout fonctionne :
1. Tester l'enregistrement avec différentes setup keys
2. Vérifier la connexion VPN
3. Tester la déconnexion/reconnexion
4. Vérifier les logs pour s'assurer qu'il n'y a pas d'erreurs

---

**Créé le** : 3 décembre 2024  
**Bundle ID** : ryvie.netbird.app  
**App Group** : group.ryvie.netbird.app  
**Team** : GW9M6A3925
