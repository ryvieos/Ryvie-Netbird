# Implémentation de la récupération automatique de la Setup Key

## Vue d'ensemble

Cette fonctionnalité permet à Ryvie-Netbird de récupérer automatiquement la setup key depuis l'API Ryvie locale, tout en conservant la possibilité d'entrée manuelle si Ryvie n'est pas détecté.

## Fonctionnement

### 1. Récupération automatique au démarrage

Lorsque l'utilisateur arrive sur l'écran d'onboarding :

1. **Recherche automatique** : L'application tente de se connecter à `http://ryvie.local:3000/api/desktop`
2. **Affichage du statut** : Un indicateur de chargement s'affiche avec le message "Recherche de Ryvie local..."
3. **Deux scénarios possibles** :
   - ✅ **Succès** : La setup key est récupérée et l'application se connecte automatiquement
   - ❌ **Échec** : Un message s'affiche indiquant que Ryvie n'a pas été détecté

### 2. Mode manuel (fallback)

Si la récupération automatique échoue :

- Un message d'avertissement s'affiche : "Ryvie local non détecté"
- Le champ de saisie manuelle de la setup key devient visible
- Un bouton "Réessayer" permet de relancer la détection automatique
- L'utilisateur peut entrer manuellement sa setup key

## Modifications apportées

### MainViewModel.swift

Ajout de la fonction `fetchSetupKeyFromRyvie()` :

```swift
func fetchSetupKeyFromRyvie() async -> String? {
    // Tente de récupérer la setup key depuis http://ryvie.local:3002/api/settings/ryvie-domains
    // Essaie plusieurs URLs en fallback (ryvie.local, localhost, 127.0.0.1)
    // Retourne la setup key si trouvée, nil sinon
}
```

### OnboardingView.swift

1. **Nouveaux états** :
   - `isFetchingFromRyvie` : Indique si la récupération est en cours
   - `showManualInput` : Contrôle l'affichage du champ de saisie manuelle
   - `ryvieNotFound` : Indique si Ryvie n'a pas été détecté

2. **Nouvelle fonction** :
   - `tryFetchSetupKeyFromRyvie()` : Gère la logique de récupération automatique

3. **Interface utilisateur** :
   - Indicateur de chargement pendant la recherche
   - Message d'avertissement si Ryvie n'est pas trouvé
   - Bouton "Réessayer" pour relancer la détection
   - Champ de saisie manuelle toujours disponible en fallback

## Comportement identique à Ryvie Desktop

Cette implémentation suit le même modèle que Ryvie Desktop :

1. **API identique** : Utilise le même endpoint `http://ryvie.local:3002/api/settings/ryvie-domains`
2. **Format de réponse** : Attend le même format JSON avec `success`, `setupKey`, `ryvieId`, `domains`, `tunnelHost`
3. **Fallback manuel** : Permet toujours l'entrée manuelle si la détection échoue
4. **Stratégie de fallback** : Essaie plusieurs URLs (ryvie.local, localhost, 127.0.0.1) avec timeout de 3 secondes

## Avantages

- ✅ **Expérience utilisateur améliorée** : Connexion automatique si Ryvie est détecté
- ✅ **Flexibilité** : Possibilité d'entrée manuelle si nécessaire
- ✅ **Cohérence** : Comportement identique à Ryvie Desktop
- ✅ **Résilience** : Gestion gracieuse des erreurs avec possibilité de réessayer

## Utilisation

### Scénario 1 : Ryvie est installé et en cours d'exécution

1. L'utilisateur lance Ryvie-Netbird
2. L'écran d'onboarding s'affiche avec "Recherche de Ryvie local..."
3. La setup key est récupérée automatiquement
4. La configuration est enregistrée
5. Le VPN se connecte automatiquement
6. L'utilisateur est redirigé vers l'écran principal avec le VPN connecté

### Scénario 2 : Ryvie n'est pas disponible

1. L'utilisateur lance Ryvie-Netbird
2. L'écran d'onboarding s'affiche avec "Recherche de Ryvie local..."
3. Après quelques secondes, le message "Ryvie local non détecté" s'affiche
4. L'utilisateur peut :
   - Cliquer sur "Réessayer" pour relancer la détection
   - Entrer manuellement sa setup key dans le champ prévu

## Tests recommandés

1. **Test avec Ryvie en cours d'exécution** :
   - Vérifier que la setup key est récupérée automatiquement
   - Vérifier que la connexion s'établit automatiquement

2. **Test sans Ryvie** :
   - Vérifier que le message d'erreur s'affiche
   - Vérifier que le champ de saisie manuelle est accessible
   - Vérifier que le bouton "Réessayer" fonctionne

3. **Test de l'entrée manuelle** :
   - Vérifier qu'une setup key valide peut être entrée manuellement
   - Vérifier la validation du format de la clé
   - Vérifier que la connexion s'établit correctement

## Notes techniques

- La récupération utilise `URLSession.shared.data(from:)` pour une requête HTTP asynchrone
- Un délai de 0.5 seconde est ajouté pour permettre l'animation de chargement
- Les transitions d'UI utilisent `withAnimation` pour une expérience fluide
- La fonction est marquée `@MainActor` pour garantir les mises à jour UI sur le thread principal
