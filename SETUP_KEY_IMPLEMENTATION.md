# Setup Key Feature - Implementation Guide

## ✅ Ce qui a été fait

J'ai implémenté la fonctionnalité de setup key directement accessible dans l'app iOS NetBird.

### Fichiers créés/modifiés :

1. **`NetBird/Source/App/Views/SetupKeyView.swift`** (NOUVEAU)
   - Vue complète pour saisir une setup key
   - Support pour serveur personnalisé (toggle optionnel)
   - Validation de la setup key avec regex
   - Gestion des erreurs et messages de succès
   - Interface utilisateur cohérente avec le reste de l'app

2. **`NetBird/Source/App/Views/Components/SideDrawer.swift`** (MODIFIÉ)
   - Ajout d'un bouton "Setup Key" dans le menu latéral
   - Navigation vers SetupKeyView

## 🔧 Étapes pour finaliser l'intégration

### 1. Ajouter le fichier au projet Xcode

Le fichier `SetupKeyView.swift` a été créé mais doit être ajouté au projet Xcode :

1. Ouvrir `NetBird.xcodeproj` dans Xcode
2. Dans le navigateur de projet (à gauche), trouver le dossier `NetBird/Source/App/Views/`
3. Faire un clic droit sur le dossier `Views` → "Add Files to NetBird..."
4. Sélectionner le fichier `SetupKeyView.swift`
5. S'assurer que :
   - ✅ "Copy items if needed" est DÉCOCHÉ (le fichier est déjà au bon endroit)
   - ✅ "Create groups" est sélectionné
   - ✅ La target "NetBird" est cochée
6. Cliquer sur "Add"

### 2. Compiler le projet

```bash
# Dans Xcode, appuyer sur Cmd+B pour compiler
# Ou utiliser le menu : Product → Build
```

Si des erreurs de compilation apparaissent, elles seront probablement liées à des imports manquants ou des noms de couleurs/images.

### 3. Tester sur un appareil physique

⚠️ **Important** : L'app ne peut pas être testée dans le simulateur iOS car elle utilise le Network Extension framework.

1. Connecter un iPhone/iPad physique
2. Sélectionner l'appareil comme destination
3. Lancer l'app (Cmd+R)
4. Ouvrir le menu latéral (hamburger)
5. Cliquer sur "Setup Key"
6. Tester l'enregistrement avec une vraie setup key

## 📱 Utilisation

### Pour l'utilisateur final :

1. **Ouvrir l'app NetBird**
2. **Cliquer sur le menu hamburger** (en haut à gauche)
3. **Sélectionner "Setup Key"**
4. **Optionnel** : Activer "Use custom server" et entrer l'URL du serveur (ex: `https://netbird.ryvie.fr:443`)
5. **Entrer la setup key** au format UUID (ex: `12345678-1234-1234-1234-123456789abc`)
6. **Cliquer sur "Register Device"**
7. **Attendre la confirmation** puis cliquer sur le bouton de connexion principal

### Serveurs supportés :

- **Par défaut** : `https://api.netbird.io` (serveur officiel NetBird)
- **Personnalisé** : N'importe quel serveur NetBird self-hosted (ex: `https://netbird.ryvie.fr:443`)

## 🎯 Fonctionnalités implémentées

✅ Champ de saisie pour la setup key avec validation regex
✅ Toggle pour utiliser un serveur personnalisé
✅ Champ de saisie pour l'URL du serveur personnalisé
✅ Validation en temps réel de la setup key
✅ Gestion des erreurs avec messages clairs
✅ Alerte de succès après enregistrement
✅ Déconnexion automatique du VPN pour forcer une reconnexion
✅ Interface cohérente avec le design de l'app
✅ Accessibilité via le menu latéral

## 🔍 Architecture technique

### Comment ça fonctionne :

1. **L'utilisateur entre la setup key** dans `SetupKeyView`
2. **Le ViewModel configure le serveur** via `updateManagementURL()`
3. **Le NetBirdSDK enregistre le peer** via `setSetupKey()` qui appelle `NetBirdSDKNewAuth().login(withSetupKeyAndSaveConfig:)`
4. **Le SDK NetBird** :
   - Contacte le management server
   - Enregistre le peer avec la setup key
   - Récupère la configuration WireGuard
   - Sauvegarde tout dans le fichier de config local
5. **L'app affiche le succès** et l'utilisateur peut se connecter

### Pas besoin de :

❌ Faire des appels API manuels (le SDK s'en charge)
❌ Configurer manuellement le `NETunnelProviderManager` (le SDK s'en charge)
❌ Gérer la configuration WireGuard manuellement (le SDK s'en charge)

## 🐛 Debugging

Si l'enregistrement échoue :

1. **Vérifier la setup key** : Format UUID correct ?
2. **Vérifier le serveur** : URL accessible ? HTTPS ?
3. **Vérifier les logs** : Menu → Advanced → Share logs
4. **Vérifier la configuration réseau** : Internet accessible ?

## 📝 Notes importantes

- La setup key doit être au format UUID : `XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`
- Le serveur doit être accessible via HTTPS
- L'app utilise le NetBirdSDK (compilé depuis le code Go) qui gère toute la logique
- Après enregistrement, l'utilisateur doit cliquer sur le bouton de connexion principal
- Si le VPN était déjà connecté, il sera déconnecté automatiquement pour forcer une reconnexion

## 🎨 Personnalisation

Si tu veux changer l'icône du bouton "Setup Key" dans le menu :

1. Ouvrir `SideDrawer.swift`
2. Ligne 60, changer `imageName: "menu-advance"` par le nom de ton icône
3. Ajouter l'icône dans `Assets.xcassets/`

## ✨ Améliorations futures possibles

- [ ] Scanner un QR code pour remplir automatiquement la setup key
- [ ] Sauvegarder l'URL du serveur personnalisé dans UserDefaults
- [ ] Afficher une liste des serveurs récemment utilisés
- [ ] Ajouter un bouton "Test Connection" pour vérifier le serveur avant l'enregistrement
- [ ] Support du deep linking pour ouvrir l'app avec une setup key pré-remplie

---

**Créé le** : 3 décembre 2024
**Auteur** : Cascade AI
