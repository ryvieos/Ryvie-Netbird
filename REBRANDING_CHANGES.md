# Rebranding Changes - Ryvie Connect

## Summary
The app has been successfully rebranded from NetBird to **Ryvie Connect** and all license dependencies have been removed.

## Changes Made

### 1. App Display Name
- **Updated**: Xcode project configuration (`NetBird.xcodeproj/project.pbxproj`)
- **Changed**: `INFOPLIST_KEY_CFBundleDisplayName` from "NetBird" to "Ryvie Connect"
- **Applies to**: Both Debug and Release configurations

### 2. Logo Updates
All logo images have been replaced with the new Ryvie logo (`ryvielogo0.png`):

#### Menu Logos
- `NetBird/Assets.xcassets/netbird-logo-menu.imageset/` (all scales: 1x, 2x, 3x, 4x)
- Light and dark mode variants updated

#### Onboarding Logos
- `NetBird/Assets.xcassets/logo-onboarding.imageset/` (all scales: 1x, 2x, 3x)

#### App Icon
- `NetBird/Assets.xcassets/AppIcon.appiconset/` (all variants)

### 3. License Dependencies Removed
**File**: `NetBird/Source/App/Views/AboutView.swift`

**Removed**:
- License agreement link (https://netbird.io/terms)
- Privacy policy link (https://netbird.io/privacy)
- Beta Program button and alert

**Added**:
- "Ryvie Connect" title display
- Updated copyright: "© 2024 Ryvie. All rights reserved."

### 4. Branding Updates
**File**: `NetBird/Source/App/Views/AdvancedView.swift`

**Updated**:
- Log file names changed from "netbird-log.txt" to "ryvie-connect-log.txt"
- Log file export name changed from "netbird.log" to "ryvie-connect.log"

## Technical Details

### Bundle Identifiers (Unchanged)
- Main app: `ryvie.netbird.app`
- Network Extension: `ryvie.netbird.app.NetbirdNetworkExtension`

### App Group (Unchanged)
- `group.ryvie.netbird.app`

### Version
- Current version: 0.0.10

## Next Steps
1. Build and test the app to ensure all changes work correctly
2. Update any external documentation or marketing materials
3. Consider updating the bundle identifiers if needed (requires provisioning profile updates)
4. Update TestFlight or App Store listings with new name and branding

## Files Modified
1. `/NetBird.xcodeproj/project.pbxproj`
2. `/NetBird/Source/App/Views/AboutView.swift`
3. `/NetBird/Source/App/Views/AdvancedView.swift`
4. All logo image files in `/NetBird/Assets.xcassets/`
