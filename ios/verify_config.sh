#!/bin/bash

# Script de vérification de la configuration NetBird iOS

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PROJECT_DIR="/Users/jules/Desktop/ios-client"
cd "$PROJECT_DIR"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Vérification de la Configuration NetBird iOS          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Fonction pour vérifier un fichier
check_file() {
    local file=$1
    local pattern=$2
    local expected=$3
    local description=$4
    
    if [ -f "$file" ]; then
        if grep -q "$pattern" "$file"; then
            local found=$(grep "$pattern" "$file" | head -1)
            if echo "$found" | grep -q "$expected"; then
                echo -e "   ${GREEN}✅${NC} $description: ${GREEN}$expected${NC}"
                return 0
            else
                echo -e "   ${RED}❌${NC} $description: ${RED}Incorrect${NC}"
                echo -e "      Trouvé: $found"
                return 1
            fi
        else
            echo -e "   ${RED}❌${NC} $description: ${RED}Non trouvé${NC}"
            return 1
        fi
    else
        echo -e "   ${RED}❌${NC} Fichier non trouvé: $file"
        return 1
    fi
}

errors=0

# 1. Vérification des App Groups
echo -e "${YELLOW}1. Vérification des App Groups${NC}"
check_file "NetbirdKit/Preferences.swift" "group.ryvie.netbird.app" "group.ryvie.netbird.app" "Preferences.swift (ligne 18)" || ((errors++))
check_file "NetbirdKit/Preferences.swift" "group.ryvie.netbird.app" "group.ryvie.netbird.app" "Preferences.swift (ligne 25)" || ((errors++))
check_file "NetbirdNetworkExtension/PacketTunnelProvider.swift" "group.ryvie.netbird.app" "group.ryvie.netbird.app" "PacketTunnelProvider.swift" || ((errors++))
check_file "NetBird/Source/App/Views/AdvancedView.swift" "group.ryvie.netbird.app" "group.ryvie.netbird.app" "AdvancedView.swift" || ((errors++))
echo ""

# 2. Vérification des Bundle IDs
echo -e "${YELLOW}2. Vérification des Bundle Identifiers${NC}"
check_file "NetbirdKit/NetworkExtensionAdapter.swift" "extensionID" "ryvie.netbird.app.NetbirdNetworkExtension" "NetworkExtensionAdapter.swift" || ((errors++))
check_file "NetBird.xcodeproj/project.pbxproj" "PRODUCT_BUNDLE_IDENTIFIER = ryvie.netbird.app;" "ryvie.netbird.app" "App principale (Xcode)" || ((errors++))
check_file "NetBird.xcodeproj/project.pbxproj" "PRODUCT_BUNDLE_IDENTIFIER = ryvie.netbird.app.NetbirdNetworkExtension;" "ryvie.netbird.app.NetbirdNetworkExtension" "Extension (Xcode)" || ((errors++))
echo ""

# 3. Vérification des Entitlements
echo -e "${YELLOW}3. Vérification des Entitlements${NC}"
check_file "NetBird/NetBird.entitlements" "group.ryvie.netbird.app" "group.ryvie.netbird.app" "NetBird.entitlements" || ((errors++))
check_file "NetbirdNetworkExtension/NetbirdNetworkExtension.entitlements" "group.ryvie.netbird.app" "group.ryvie.netbird.app" "NetbirdNetworkExtension.entitlements" || ((errors++))
check_file "NetBird/NetBird.entitlements" "packet-tunnel-provider" "packet-tunnel-provider" "Network Extension capability (App)" || ((errors++))
check_file "NetbirdNetworkExtension/NetbirdNetworkExtension.entitlements" "packet-tunnel-provider" "packet-tunnel-provider" "Network Extension capability (Extension)" || ((errors++))
echo ""

# 4. Vérification de la structure du projet
echo -e "${YELLOW}4. Vérification de la Structure du Projet${NC}"
if [ -d "NetbirdNetworkExtension" ]; then
    echo -e "   ${GREEN}✅${NC} Dossier NetbirdNetworkExtension existe"
else
    echo -e "   ${RED}❌${NC} Dossier NetbirdNetworkExtension manquant"
    ((errors++))
fi

if [ -f "NetbirdNetworkExtension/PacketTunnelProvider.swift" ]; then
    echo -e "   ${GREEN}✅${NC} PacketTunnelProvider.swift existe"
else
    echo -e "   ${RED}❌${NC} PacketTunnelProvider.swift manquant"
    ((errors++))
fi

if [ -f "NetbirdNetworkExtension/Info.plist" ]; then
    echo -e "   ${GREEN}✅${NC} Info.plist (Extension) existe"
    if grep -q "com.apple.networkextension.packet-tunnel" "NetbirdNetworkExtension/Info.plist"; then
        echo -e "   ${GREEN}✅${NC} Extension Point Identifier correct"
    else
        echo -e "   ${RED}❌${NC} Extension Point Identifier incorrect"
        ((errors++))
    fi
else
    echo -e "   ${RED}❌${NC} Info.plist (Extension) manquant"
    ((errors++))
fi
echo ""

# 5. Vérification des anciennes références
echo -e "${YELLOW}5. Vérification des Anciennes Références (io.netbird.app)${NC}"
old_refs=$(grep -r "io\.netbird\.app" --include="*.swift" --include="*.plist" --include="*.entitlements" . 2>/dev/null | grep -v ".git" | grep -v "verify_config.sh" | wc -l | tr -d ' ')
if [ "$old_refs" -eq "0" ]; then
    echo -e "   ${GREEN}✅${NC} Aucune ancienne référence trouvée"
else
    echo -e "   ${RED}❌${NC} $old_refs anciennes références trouvées:"
    grep -r "io\.netbird\.app" --include="*.swift" --include="*.plist" --include="*.entitlements" . 2>/dev/null | grep -v ".git" | grep -v "verify_config.sh" | sed 's/^/      /'
    ((errors++))
fi
echo ""

# Résumé
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
if [ $errors -eq 0 ]; then
    echo -e "${BLUE}║${NC}  ${GREEN}✅ Configuration Correcte - Aucune Erreur Détectée${NC}      ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}Prochaines étapes:${NC}"
    echo "1. Ouvrir NetBird.xcodeproj dans Xcode"
    echo "2. Vérifier manuellement les Signing & Capabilities"
    echo "3. Clean Build Folder (Cmd+Shift+K)"
    echo "4. Rebuild (Cmd+B)"
    echo "5. Désinstaller l'ancienne app de l'appareil"
    echo "6. Installer et tester"
else
    echo -e "${BLUE}║${NC}  ${RED}❌ $errors Erreur(s) Détectée(s) - Correction Nécessaire${NC}   ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${RED}Veuillez corriger les erreurs ci-dessus avant de continuer.${NC}"
    exit 1
fi
