# Simplification de l'Interface - Ryvie Connect

## Résumé des Modifications

L'interface a été simplifiée selon vos demandes pour se concentrer sur l'essentiel.

## Changements Effectués

### 1. Menu Latéral Simplifié
**Fichier**: `NetBird/Source/App/Views/Components/SideDrawer.swift`

**Éléments retirés** :
- ❌ "Advanced" (paramètres avancés)
- ❌ "Docs" (lien vers la documentation)
- ❌ "Change Server" (changement de serveur)

**Éléments conservés** :
- ✅ "Setup Key" (gestion de la clé de configuration)
- ✅ "About" (informations sur l'application)

### 2. Gestion Simplifiée de la Clé
**Fichier**: `NetBird/Source/App/Views/SetupKeyView.swift`

**Nouveau comportement** :
- Si **aucune clé n'est configurée** : affiche un formulaire pour entrer une nouvelle clé
- Si **une clé existe déjà** : affiche un bouton "Remove Setup Key" pour la retirer

**Fonctionnalités** :
- Vérification automatique de la présence d'une clé au chargement
- Connexion automatique après l'ajout d'une clé
- Déconnexion automatique lors de la suppression d'une clé
- Validation du format de la clé avant soumission

### 3. Couleurs Mises à Jour
**Fichier**: `NetBird/Assets.xcassets/AccentColor.colorset/Contents.json`

**Changement** :
- Ancienne couleur : Orange (#F68330)
- **Nouvelle couleur** : Bleu Cyan Ryvie (#5DD7F3)

Cette couleur correspond au logo Ryvie et donne une identité visuelle cohérente à l'application.

### 4. Textes Mis à Jour
**Fichiers modifiés** :
- `MainView.swift` : Suppression des références à "NetBird"
- `SetupKeyView.swift` : Textes adaptés pour "Ryvie network"

## Flux Utilisateur Simplifié

### Premier Lancement
1. L'utilisateur ouvre l'app
2. Va dans le menu → "Setup Key"
3. Entre sa clé de configuration
4. L'app se connecte automatiquement

### Changement de Clé
1. L'utilisateur va dans le menu → "Setup Key"
2. Clique sur "Remove Setup Key"
3. Entre une nouvelle clé
4. L'app se reconnecte automatiquement

## Éléments Techniques

### Serveur par Défaut
Le serveur est configuré automatiquement sur : `https://netbird.ryvie.fr`

### Stockage de la Clé
La clé est stockée de manière sécurisée via `Preferences` (NetbirdKit)

### Gestion de l'État
- Vérification automatique de la présence d'une clé à l'ouverture de SetupKeyView
- Déconnexion automatique avant suppression de la clé
- Reconnexion automatique après ajout d'une clé

## Interface Épurée

Le menu latéral ne contient maintenant que :
```
┌─────────────────────┐
│   [Logo Ryvie]      │
│                     │
│  📋 Setup Key       │
│  ℹ️  About          │
│                     │
│                     │
│  Version X.X.X      │
└─────────────────────┘
```

## Prochaines Étapes Recommandées

1. ✅ Tester l'ajout d'une clé
2. ✅ Tester la suppression d'une clé
3. ✅ Vérifier la connexion automatique
4. ✅ Valider les nouvelles couleurs
5. ✅ Tester sur différents appareils (iPhone/iPad)

## Notes

- Les paramètres avancés (pre-shared key, logs, Rosenpass) ne sont plus accessibles via l'interface
- La documentation externe n'est plus liée depuis l'app
- Le changement de serveur n'est plus possible (serveur fixe : netbird.ryvie.fr)
- L'interface est maintenant focalisée sur la simplicité d'utilisation
