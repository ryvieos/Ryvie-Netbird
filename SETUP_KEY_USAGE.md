# 🔑 Setup Key - Guide d'utilisation

## ✅ Configuration terminée

L'app iOS NetBird est maintenant configurée pour utiliser votre serveur NetBird personnalisé.

### Serveur par défaut
- **URL** : `https://netbird.ryvie.fr`
- Configuré automatiquement, pas besoin de le saisir

## 📱 Comment utiliser

### 1. Ouvrir l'app NetBird
Sur votre iPhone/iPad (⚠️ **pas le simulateur**)

### 2. Accéder au menu Setup Key
- Cliquer sur le **menu hamburger** (☰) en haut à gauche
- Sélectionner **"Setup Key"**

### 3. Enregistrer et connecter automatiquement
- Entrer votre **setup key** (format UUID)
  ```
  Exemple: 12345678-1234-1234-1234-123456789abc
  ```
- Cliquer sur **"Register Device"**
- L'app va automatiquement :
  - ✅ Enregistrer l'appareil
  - ✅ Fermer le menu
  - ✅ Se connecter au VPN
- Profiter de votre VPN NetBird ! 🎉

## 🔍 Format de la Setup Key

La setup key doit être au format **UUID** :
```
XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
```

Où `X` = caractère hexadécimal (0-9, A-F)

## ⚠️ Notes importantes

### Simulateur iOS
Les erreurs suivantes sont **normales** dans le simulateur :
```
Failed to load configurations: Error Domain=NEConfigurationErrorDomain Code=11 "IPC failed"
Error loading from preferences: Error Domain=NEVPNErrorDomain Code=5 "IPC failed"
```

**Pourquoi ?** Le Network Extension framework ne fonctionne pas dans le simulateur iOS.

**Solution :** Utiliser un **appareil physique** (iPhone/iPad)

### Erreurs haptiques
Ces erreurs sont également normales et sans impact :
```
Error creating CHHapticPattern: Error Domain=NSCocoaErrorDomain Code=260
"The file "hapticpatternlibrary.plist" couldn't be opened"
```

Ce sont des warnings du simulateur, ignorez-les.

## 🐛 Dépannage

### "Failed to connect to server"
- ✅ Vérifier que `https://netbird.ryvie.fr` est accessible
- ✅ Vérifier votre connexion Internet
- ✅ Vérifier que le serveur NetBird est en ligne

### "Failed to register with setup key"
- ✅ Vérifier que la setup key est correcte
- ✅ Vérifier que la setup key n'a pas expiré
- ✅ Vérifier qu'elle n'a pas déjà été utilisée (si usage unique)

### "IPC failed" dans le simulateur
- ✅ **Normal !** Utiliser un appareil physique

## 🎯 Prochaines étapes

1. **Tester sur un appareil réel**
   - Connecter un iPhone/iPad via USB
   - Dans Xcode : Product → Destination → [Votre appareil]
   - Product → Run (Cmd+R)

2. **Obtenir une setup key**
   - Se connecter au dashboard NetBird : `https://netbird.ryvie.fr`
   - Aller dans Settings → Setup Keys
   - Créer ou copier une setup key existante

3. **Enregistrer l'appareil**
   - Suivre les étapes ci-dessus
   - Profiter ! 🚀

## 📝 Changelog

### Version actuelle
- ✅ Interface simplifiée : juste la setup key à saisir
- ✅ Serveur par défaut : `https://netbird.ryvie.fr`
- ✅ Validation automatique du format UUID
- ✅ Messages d'erreur clairs
- ✅ **Connexion automatique** après enregistrement réussi
- ✅ Retour automatique à l'écran principal

---

**Créé le** : 3 décembre 2024  
**Serveur** : https://netbird.ryvie.fr
