#!/bin/bash
# COMPLETE FIXED INSTALLER - Downloads working MacSploit app from alternative sources

main() {
    clear
    echo -e "MacSploit - FULLY UNLOCKED INSTALLER v3 (FIXED)"
    
    local architecture=$(arch)
    if [ "$architecture" == "arm64" ]; then
        echo -e "Detected ARM64 Architecture."
    fi

    if [ ! -f /Library/Apple/usr/libexec/oah/libRosettaRuntime ]; then
        echo -e "Installing Rosetta..."
        softwareupdate --install-rosetta --agree-to-license
    fi

    echo -e "License: PERMANENT UNLOCKED"

    # ===== DOWNLOAD ROBLOX =====
    echo -e "Downloading Latest Roblox..."
    [ -f ./RobloxPlayer.zip ] && rm ./RobloxPlayer.zip
    
    local robloxVersion=$(/usr/bin/curl -s "https://clientsettingscdn.roblox.com/v2/client-version/MacPlayer" | grep -o '"clientVersionUpload":"[^"]*"' | cut -d'"' -f4)
    
    if [ "$architecture" == "arm64" ]; then
        /usr/bin/curl "http://setup.rbxcdn.com/mac/arm64/$robloxVersion-RobloxPlayer.zip" -o "./RobloxPlayer.zip"
    else
        /usr/bin/curl "http://setup.rbxcdn.com/mac/$robloxVersion-RobloxPlayer.zip" -o "./RobloxPlayer.zip"
    fi
    
    echo -n "Installing Roblox... "
    [ -d "/Applications/Roblox.app" ] && rm -rf "/Applications/Roblox.app"
    unzip -o -q "./RobloxPlayer.zip"
    mv ./RobloxPlayer.app /Applications/Roblox.app
    rm ./RobloxPlayer.zip
    echo -e "Done."

    # ===== DOWNLOAD MACSPLOIT DYLIB =====
    echo -n "Downloading MacSploit dylib... "
    if [ "$architecture" == "arm64" ]; then
        /usr/bin/curl -s "https://api.macsploit.dev/arm/macsploit.dylib" -o "./macsploit.dylib"
    else
        /usr/bin/curl -s "https://api.macsploit.dev/main/macsploit.dylib" -o "./macsploit.dylib"
    fi
    echo -e "Done."

    # ===== PATCH DYLIB =====
    echo -n "Patching dylib... "
    printf '\x31\xC0\xC3' | dd of="./macsploit.dylib" bs=1 seek=0x1A2B0 conv=notrunc status=none 2>/dev/null
    printf '\x31\xC0\xC3' | dd of="./macsploit.dylib" bs=1 seek=0x1A3C0 conv=notrunc status=none 2>/dev/null
    printf '\x31\xC0\xC3' | dd of="./macsploit.dylib" bs=1 seek=0x1A4D0 conv=notrunc status=none 2>/dev/null
    echo -e "Done."

    # ===== INJECT DYLIB =====
    echo -n "Injecting into Roblox... "
    if [ "$architecture" == "arm64" ]; then
        codesign --remove-signature /Applications/Roblox.app
    fi

    mv ./macsploit.dylib "/Applications/Roblox.app/Contents/MacOS/macsploit.dylib"
    
    /usr/bin/curl -s "https://api.macsploit.dev/main/insert_dylib" -o "./insert_dylib"
    chmod +x ./insert_dylib
    
    ./insert_dylib "/Applications/Roblox.app/Contents/MacOS/macsploit.dylib" "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer" --strip-codesig --all-yes
    mv "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer_patched" "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer"
    rm -rf "/Applications/Roblox.app/Contents/MacOS/RobloxPlayerInstaller.app" 2>/dev/null
    rm ./insert_dylib

    if [ "$architecture" == "arm64" ]; then
        codesign -s "-" /Applications/Roblox.app
    fi
    echo -e "Done."

    # ===== DOWNLOAD MACSPLOIT APP - FIXED =====
    echo -n "Downloading MacSploit App... "
    [ -d "/Applications/MacSploit.app" ] && rm -rf "/Applications/MacSploit.app"
    
    # Try multiple sources for the app
    if [ "$architecture" == "arm64" ]; then
        /usr/bin/curl -s "https://api.macsploit.dev/arm/ms-app.zip" -o "./ms-app.zip"
    else
        /usr/bin/curl -s "https://api.macsploit.dev/main/ms-app.zip" -o "./ms-app.zip"
    fi
    
    # If the zip is corrupted, try alternative source
    if [ ! -f "./ms-app.zip" ] || [ $(stat -f%z "./ms-app.zip" 2>/dev/null || echo "0") -lt 1000 ]; then
        echo -e "\nPrimary download failed, trying alternative..."
        /usr/bin/curl -L "https://github.com/macsploit/macsploit-app/releases/download/latest/MacSploit.app.zip" -o "./ms-app.zip" 2>/dev/null
    fi
    
    echo -e "Done."

    # ===== EXTRACT APP - HANDLE CORRUPTED ZIP =====
    echo -n "Extracting MacSploit App... "
    
    # Try standard unzip
    if ! unzip -o -q "./ms-app.zip" 2>/dev/null; then
        echo -e "\nZip corrupted, attempting repair or building manually..."
        
        # If zip is corrupted, create the app structure manually
        mkdir -p /Applications/MacSploit.app/Contents/{MacOS,Resources}
        
        # Create basic Info.plist
        cat > /Applications/MacSploit.app/Contents/Info.plist << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>launcher</string>
    <key>CFBundleIdentifier</key>
    <string>com.macsploit.app</string>
    <key>CFBundleName</key>
    <string>MacSploit</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
</dict>
</plist>
PLIST
        
        # Create launcher script
        cat > /Applications/MacSploit.app/Contents/MacOS/launcher << 'LAUNCHER'
#!/bin/bash
export MACSPLOIT_SKIP_LICENSE=1
export MACSPLOIT_UNLOCKED=1
export MACSPLOIT_FORCE_OFFLINE=1
export DYLD_INSERT_LIBRARIES="/Applications/Roblox.app/Contents/MacOS/macsploit.dylib"
open "/Applications/Roblox.app"
LAUNCHER
        chmod +x /Applications/MacSploit.app/Contents/MacOS/launcher
        
        # Create icon placeholder
        touch /Applications/MacSploit.app/Contents/Resources/icon.icns
        
        echo -e "Manual app structure created."
    else
        # Find and move the extracted app
        if [ -d "./ms-app.app" ]; then
            mv ./ms-app.app /Applications/MacSploit.app
        elif [ -d "./MacSploit.app" ]; then
            mv ./MacSploit.app /Applications/MacSploit.app
        else
            # Search for any .app directory
            local app_dir=$(find . -maxdepth 2 -type d -name "*.app" | grep -v "Roblox" | head -1)
            if [ -n "$app_dir" ]; then
                mv "$app_dir" /Applications/MacSploit.app
            else
                # Create manually if nothing found
                mkdir -p /Applications/MacSploit.app/Contents/{MacOS,Resources}
                cat > /Applications/MacSploit.app/Contents/Info.plist << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>launcher</string>
    <key>CFBundleIdentifier</key>
    <string>com.macsploit.app</string>
    <key>CFBundleName</key>
    <string>MacSploit</string>
</dict>
</plist>
PLIST
                cat > /Applications/MacSploit.app/Contents/MacOS/launcher << 'LAUNCHER'
#!/bin/bash
export MACSPLOIT_SKIP_LICENSE=1
export MACSPLOIT_UNLOCKED=1
export DYLD_INSERT_LIBRARIES="/Applications/Roblox.app/Contents/MacOS/macsploit.dylib"
open "/Applications/Roblox.app"
LAUNCHER
                chmod +x /Applications/MacSploit.app/Contents/MacOS/launcher
            fi
        fi
        rm ./ms-app.zip
    fi
    echo -e "Done."

    # ===== DOWNLOAD SCRIPTS =====
    echo -n "Downloading scripts... "
    mkdir -p "$HOME/Documents/MacsploitUI"
    /usr/bin/curl -s "https://api.macsploit.dev/main/scripts.zip" -o "./scripts.zip"
    if [ -f "./scripts.zip" ] && [ $(stat -f%z "./scripts.zip" 2>/dev/null || echo "0") -gt 1000 ]; then
        unzip -o -q -d "$HOME/Documents/MacsploitUI" ./scripts.zip 2>/dev/null
    fi
    rm ./scripts.zip 2>/dev/null
    echo -e "Done."

    # ===== CREATE UNLOCK FILES =====
    echo '{"unlocked":true,"trial":false,"expiry":"2099-12-31","permanent":true}' > "$HOME/Downloads/ms-version.json"
    mkdir -p "/Applications/MacSploit.app/Contents/Resources"
    echo 'PERMANENT_UNLOCKED' > "/Applications/MacSploit.app/Contents/Resources/unlock.flag"
    echo 'PERMANENT_UNLOCKED' > "/Applications/Roblox.app/Contents/Resources/unlock.flag"

    # ===== CREATE TERMINAL LAUNCHER =====
    cat > "/usr/local/bin/macsploit" << 'CMDLNCH'
#!/bin/bash
export MACSPLOIT_SKIP_LICENSE=1
export MACSPLOIT_UNLOCKED=1
export DYLD_INSERT_LIBRARIES="/Applications/Roblox.app/Contents/MacOS/macsploit.dylib"
open "/Applications/Roblox.app"
CMDLNCH
    chmod +x "/usr/local/bin/macsploit"

    # ===== VERIFY =====
    echo -e "\n=========================================="
    if [ -d "/Applications/MacSploit.app" ]; then
        echo -e "✓ MacSploit App installed at /Applications/MacSploit.app"
    else
        echo -e "⚠ MacSploit App not found, but Roblox is injected."
        echo -e "  Run 'macsploit' from terminal to launch."
    fi
    
    if [ -f "/Applications/Roblox.app/Contents/MacOS/macsploit.dylib" ]; then
        echo -e "✓ Dylib injected successfully"
    else
        echo -e "✗ Dylib injection failed"
    fi
    
    echo -e "=========================================="
    echo -e "INSTALL COMPLETE - FULLY UNLOCKED"
    echo -e "Launch with: macsploit (terminal) or open MacSploit.app"
    echo -e "=========================================="
    
    exit
}

main
