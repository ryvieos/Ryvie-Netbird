# 🔍 Debug Logs - NetBird Setup Key

## Logs ajoutés

J'ai ajouté des logs détaillés avec des emojis pour faciliter le debugging dans la console Xcode.

### 📍 Emplacements des logs

#### 1. **SetupKeyView.swift** - Vue d'enregistrement
```
🔑 Starting registration with setup key
🌐 Configuring server URL
✅ Server configured successfully
📝 Calling setSetupKey...
✅ Device registered successfully!
🔙 Closing menu and returning to main screen
⏳ Waiting 1 second for configuration to be saved...
🔍 Current extension state: [state]
🔌 Extension is connected, disconnecting first...
⏳ Waiting 3 seconds for disconnection...
🔍 Checking extension state after disconnect...
🚀 Attempting to connect...
✅ Connect() called successfully
```

#### 2. **MainViewModel.swift** - Logique métier
```
📝 setSetupKey() called with key: [first 8 chars]...
🌐 Management URL: [url]
📁 Config file: [path]
📱 Device name: [name]
🔐 NetBirdSDK Auth object created
✅ login(withSetupKeyAndSaveConfig) completed successfully
🧹 Management URL cleared

🚀 connect() called
🔍 Current extension state: [state]
✅ connectPressed set to true
🔌 Starting extension...
⏳ Calling networkExtensionAdapter.start()...
✅ networkExtensionAdapter.start() completed
🔍 New extension state: [state]
🔓 Button lock released
```

#### 3. **NetworkExtensionAdapter.swift** - Adaptateur VPN
```
🚀 start() called
⚙️ Configuring manager...
✅ Extension configured successfully
🔐 Checking if login is required...
✅ start() completed

🚀 startVPNConnection() called
✅ Session available: [session]
🔍 Session status: [status]
📝 Log level: [level]
⏳ Calling startVPNTunnel...
✅ VPN Tunnel start command sent successfully
```

## 🎯 Comment utiliser ces logs

### 1. Ouvrir la console Xcode
- **Xcode** → **View** → **Debug Area** → **Show Debug Area**
- Ou raccourci : **Cmd + Shift + Y**

### 2. Filtrer les logs
Dans la barre de recherche de la console, chercher :
- `[SetupKeyView]` - Pour voir les logs de la vue
- `[ViewModel]` - Pour voir les logs du ViewModel
- `[NetworkExtensionAdapter]` - Pour voir les logs de l'adaptateur
- `🔑` ou `🚀` ou `❌` - Pour filtrer par type d'événement

### 3. Flux normal attendu

Voici ce que tu devrais voir dans les logs lors d'un enregistrement réussi :

```
🔑 [SetupKeyView] Starting registration with setup key
🌐 [SetupKeyView] Configuring server URL: https://netbird.ryvie.fr
✅ [SetupKeyView] Server configured successfully, SSO supported: false
📝 [SetupKeyView] Calling setSetupKey...
📝 [ViewModel] setSetupKey() called with key: 12345678...
🌐 [ViewModel] Management URL: https://netbird.ryvie.fr
📁 [ViewModel] Config file: /path/to/netbird.cfg
📱 [ViewModel] Device name: iPhone de Jules
🔐 [ViewModel] NetBirdSDK Auth object created
✅ [ViewModel] login(withSetupKeyAndSaveConfig) completed successfully
🧹 [ViewModel] Management URL cleared
✅ [SetupKeyView] Device registered successfully!
🔙 [SetupKeyView] Closing menu and returning to main screen
⏳ [SetupKeyView] Waiting 1 second for configuration to be saved...
🔍 [SetupKeyView] Current extension state: disconnected
🔍 [SetupKeyView] Extension is disconnected, checking state...
🚀 [SetupKeyView] Attempting to connect...
✅ [SetupKeyView] Connect() called successfully
🚀 [ViewModel] connect() called
🔍 [ViewModel] Current extension state: disconnected
✅ [ViewModel] connectPressed set to true
🔌 [ViewModel] Starting extension...
⏳ [ViewModel] Calling networkExtensionAdapter.start()...
🚀 [NetworkExtensionAdapter] start() called
⚙️ [NetworkExtensionAdapter] Configuring manager...
✅ [NetworkExtensionAdapter] Extension configured successfully
🔐 [NetworkExtensionAdapter] Checking if login is required...
🚀 [NetworkExtensionAdapter] startVPNConnection() called
✅ [NetworkExtensionAdapter] Session available: <NETunnelProviderSession>
🔍 [NetworkExtensionAdapter] Session status: disconnected
📝 [NetworkExtensionAdapter] Log level: INFO
⏳ [NetworkExtensionAdapter] Calling startVPNTunnel...
✅ [NetworkExtensionAdapter] VPN Tunnel start command sent successfully
✅ [NetworkExtensionAdapter] start() completed
✅ [ViewModel] networkExtensionAdapter.start() completed
🔍 [ViewModel] New extension state: connecting
🔓 [ViewModel] Button lock released
```

## 🚨 Erreurs possibles

### Erreur 1 : Session non disponible
```
❌ [NetworkExtensionAdapter] No session available!
```
**Cause** : L'extension VPN n'est pas configurée correctement.
**Solution** : Vérifier que l'extension est bien installée dans les réglages iOS.

### Erreur 2 : Échec de l'enregistrement
```
❌ [SetupKeyView] Registration failed: [error]
```
**Cause** : La setup key est invalide ou le serveur est inaccessible.
**Solution** : Vérifier la setup key et la connexion Internet.

### Erreur 3 : Échec du démarrage de l'extension
```
❌ [NetworkExtensionAdapter] Failed to start extension: [error]
```
**Cause** : Problème de configuration ou de permissions.
**Solution** : Redémarrer l'app ou l'appareil.

### Erreur 4 : Échec du tunnel VPN
```
❌ [NetworkExtensionAdapter] Failed to start VPN tunnel: [error]
```
**Cause** : L'extension ne peut pas démarrer le tunnel.
**Solution** : Vérifier les permissions VPN dans les réglages iOS.

## 📊 États de l'extension VPN

Les états possibles de `extensionState` :

- `invalid` (0) - Configuration invalide
- `disconnected` (1) - Déconnecté
- `connecting` (2) - En cours de connexion ⏳
- `connected` (3) - Connecté ✅
- `reasserting` (4) - Reconnexion en cours
- `disconnecting` (5) - Déconnexion en cours

## 🔧 Debugging avancé

### Si l'app reste en "Connecting..." à l'infini

Chercher dans les logs :

1. **L'état de l'extension change-t-il ?**
   ```
   🔍 [ViewModel] Current extension state: connecting
   ```
   Si ça reste sur `connecting`, le problème est dans l'extension VPN elle-même.

2. **La session est-elle disponible ?**
   ```
   ✅ [NetworkExtensionAdapter] Session available: <NETunnelProviderSession>
   ```
   Si non, l'extension n'est pas configurée.

3. **Le tunnel démarre-t-il ?**
   ```
   ✅ [NetworkExtensionAdapter] VPN Tunnel start command sent successfully
   ```
   Si oui mais que ça ne connecte pas, le problème est dans l'extension réseau.

4. **Y a-t-il des erreurs IPC ?**
   ```
   Failed to load configurations: Error Domain=NEConfigurationErrorDomain Code=11 "IPC failed"
   ```
   Sur **appareil réel** : Problème de communication avec l'extension.
   Sur **simulateur** : Normal, ignorer.

### Logs de l'extension réseau

Pour voir les logs de l'extension elle-même (PacketTunnelProvider), chercher :
```
[INFO] client/internal/...
[ERRO] shared/management/...
```

Ces logs viennent du SDK Go NetBird et indiquent ce qui se passe dans l'extension.

## 💡 Conseils

1. **Toujours tester sur un appareil réel** (pas le simulateur)
2. **Filtrer les logs** pour ne voir que ce qui t'intéresse
3. **Chercher les ❌** pour identifier rapidement les erreurs
4. **Vérifier les états** pour comprendre où ça bloque
5. **Comparer avec le flux normal** ci-dessus

## 📝 Exemple de session de debug

1. Lancer l'app depuis Xcode
2. Ouvrir la console (Cmd + Shift + Y)
3. Filtrer sur `[SetupKeyView]`
4. Entrer la setup key et cliquer "Register"
5. Observer le flux des logs
6. Si erreur, chercher le premier `❌`
7. Lire le message d'erreur associé
8. Appliquer la solution correspondante

---

**Créé le** : 3 décembre 2024  
**Version** : 1.0
