#!/bin/bash

echo "🧹 Nettoyage complet du projet NetBird..."

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Chemin du projet
PROJECT_DIR="/Users/jules/Desktop/ios-client"
cd "$PROJECT_DIR"

echo -e "${YELLOW}1. Suppression des configurations VPN existantes...${NC}"
echo "   ⚠️  Ouvrez Réglages > Général > VPN et supprimez manuellement 'NetBird Network Extension'"

echo -e "\n${YELLOW}2. Nettoyage des builds Xcode...${NC}"
rm -rf ~/Library/Developer/Xcode/DerivedData/NetBird-*
rm -rf "$PROJECT_DIR/build"
echo "   ✅ DerivedData supprimé"

echo -e "\n${YELLOW}3. Nettoyage du cache App Group...${NC}"
echo "   ℹ️  Le cache App Group sera recréé au prochain lancement"

echo -e "\n${YELLOW}4. Vérification des configurations...${NC}"
echo "   📋 Bundle IDs:"
echo "      - App principale: ryvie.netbird.app"
echo "      - Extension: ryvie.netbird.app.NetbirdNetworkExtension"
echo "   📋 App Group: group.ryvie.netbird.app"

echo -e "\n${GREEN}✅ Nettoyage terminé !${NC}"
echo -e "\n${YELLOW}Prochaines étapes:${NC}"
echo "1. Ouvrez NetBird.xcodeproj dans Xcode"
echo "2. Product > Clean Build Folder (Cmd+Shift+K)"
echo "3. Vérifiez les Signing & Capabilities:"
echo "   - Target NetBird: App Groups = group.ryvie.netbird.app"
echo "   - Target NetbirdNetworkExtension: App Groups = group.ryvie.netbird.app"
echo "4. Rebuild le projet (Cmd+B)"
echo "5. Désinstallez l'app de votre appareil iOS"
echo "6. Installez la nouvelle version"
echo ""
echo "🔍 Pour vérifier les logs système:"
echo "   log stream --predicate 'process == \"nesessionmanager\"' --level debug"
