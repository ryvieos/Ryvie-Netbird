# 🔧 Troubleshooting - NetBird iOS Setup Key

## ✅ L'enregistrement fonctionne mais pas la connexion

### Symptômes
- ✅ L'appareil apparaît dans le dashboard NetBird
- ❌ L'appareil reste "Disconnected" dans le dashboard
- ❌ L'app affiche "Connecting..." mais ne se connecte jamais

### Causes possibles

#### 1. **Délai insuffisant après l'enregistrement**
La configuration NetBird doit être complètement écrite sur le disque avant de pouvoir se connecter.

**Solution actuelle** : L'app attend maintenant 1 seconde après l'enregistrement avant de tenter la connexion.

#### 2. **Extension VPN non chargée**
L'extension Network Extension doit être chargée par iOS avant de pouvoir se connecter.

**Solution actuelle** : L'app appelle `checkExtensionState()` avant de se connecter.

#### 3. **Permissions VPN non accordées**
iOS doit demander la permission d'installer un profil VPN.

**Solution** : 
- Lors de la première connexion, iOS affichera une popup
- Cliquer sur "Allow" / "Autoriser"
- Entrer le code PIN de l'appareil si demandé

### Logs à surveiller

#### Logs normaux (succès)
```
[INFO] client/internal/profilemanager/config.go:222 using default Management URL
[INFO] client/internal/profilemanager/config.go:229 new Management URL provided, updated to "https://netbird.ryvie.fr"
```

#### Logs d'erreur (problème)
```
Failed to load configurations: Error Domain=NEConfigurationErrorDomain Code=11 "IPC failed"
Error loading from preferences: Error Domain=NEVPNErrorDomain Code=5 "IPC failed"
```

**Note** : Ces erreurs IPC sont **normales dans le simulateur** mais **pas sur un appareil réel**.

## 🔄 Solutions alternatives

### Option 1 : Connexion manuelle
Si la connexion automatique ne fonctionne pas :

1. Enregistrer l'appareil avec la setup key
2. **Attendre 2-3 secondes**
3. Cliquer **manuellement** sur le bouton de connexion principal

### Option 2 : Redémarrer l'app
Parfois, iOS a besoin d'un redémarrage pour charger l'extension VPN :

1. Enregistrer l'appareil
2. **Fermer complètement l'app** (swipe up)
3. **Rouvrir l'app**
4. Cliquer sur le bouton de connexion

### Option 3 : Vérifier les permissions
1. Aller dans **Réglages iOS** → **Général** → **VPN et gestion des appareils**
2. Vérifier que **NetBird** apparaît dans la liste
3. Si absent, réinstaller l'app

## 🐛 Debugging avancé

### Vérifier la configuration NetBird

Le fichier de configuration est stocké dans :
```
/var/mobile/Containers/Shared/AppGroup/[UUID]/netbird.cfg
```

### Vérifier les logs de l'extension

Les logs de l'extension Network Extension sont dans :
```
/var/mobile/Containers/Shared/AppGroup/[UUID]/logfile.log
```

Pour les récupérer :
1. Ouvrir l'app NetBird
2. Menu → **Advanced**
3. Cliquer sur **Share logs**

### Erreurs courantes

#### "Connection interrupted"
```
-[NETunnelProviderSession startTunnelWithOptions:] block_invoke 
Client connection to service was interrupted
```

**Cause** : L'extension VPN s'est arrêtée de manière inattendue.

**Solution** :
- Attendre plus longtemps après l'enregistrement (1-2 secondes)
- Vérifier que l'extension est bien installée dans les réglages iOS

#### "IPC failed"
```
Error Domain=NEVPNErrorDomain Code=5 "IPC failed"
```

**Cause** : Communication impossible entre l'app et l'extension VPN.

**Solution** :
- Sur **simulateur** : Normal, ignorer
- Sur **appareil réel** : Redémarrer l'app ou l'appareil

## 📱 Test sur appareil réel

### Checklist avant de tester

- [ ] L'app est installée sur un **appareil physique** (pas simulateur)
- [ ] L'appareil a une **connexion Internet**
- [ ] Le serveur `https://netbird.ryvie.fr` est **accessible**
- [ ] La setup key est **valide** et **non expirée**
- [ ] Les **permissions VPN** ont été accordées

### Procédure de test complète

1. **Désinstaller l'app** (si déjà installée)
2. **Réinstaller** depuis Xcode
3. **Ouvrir l'app**
4. **Menu** → Setup Key
5. **Entrer la setup key**
6. **Cliquer "Register Device"**
7. **Autoriser** le profil VPN si demandé
8. **Attendre** 3-5 secondes
9. **Vérifier** que l'app affiche "Connected"
10. **Vérifier** dans le dashboard que l'appareil est "Connected"

## 🎯 Amélioration future possible

Si la connexion automatique continue à poser problème, on peut :

1. **Supprimer la connexion automatique**
   - Juste enregistrer l'appareil
   - Afficher un message "Device registered! Tap the button to connect"
   - L'utilisateur clique manuellement sur le bouton

2. **Ajouter un indicateur de progression**
   - "Registering device..."
   - "Device registered ✓"
   - "Connecting to VPN..."
   - "Connected ✓"

3. **Ajouter une vérification de l'état**
   - Après l'enregistrement, vérifier que la config existe
   - Vérifier que l'extension est chargée
   - Seulement alors tenter la connexion

## 📞 Support

Si le problème persiste :

1. **Récupérer les logs** (Menu → Advanced → Share logs)
2. **Vérifier le dashboard NetBird** (l'appareil est-il enregistré ?)
3. **Vérifier les réglages iOS** (le profil VPN est-il installé ?)
4. **Essayer une connexion manuelle** (bouton principal)

---

**Créé le** : 3 décembre 2024  
**Version** : 1.0
