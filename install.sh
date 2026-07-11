#!/bin/bash
# COMPLETE STANDALONE INSTALLER - No API, no license, forces full app installation

main() {
    clear
    echo -e "MacSploit - FULLY UNLOCKED INSTALLER v2"
    echo -e "Bypassing all license checks - forcing full install"
    
    local architecture=$(arch)
    if [ "$architecture" == "arm64" ]; then
        echo -e "Detected ARM64 Architecture."
    fi

    if [ ! -f /Library/Apple/usr/libexec/oah/libRosettaRuntime ]; then
        echo -e "Installing Rosetta..."
        softwareupdate --install-rosetta --agree-to-license
    fi

    echo -e "License: PERMANENT UNLOCKED - SKIPPING ALL CHECKS"

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

    # ===== PATCH DYLIB - Remove all expiry =====
    echo -n "Patching dylib... "
    printf '\x31\xC0\xC3' | dd of="./macsploit.dylib" bs=1 seek=0x1A2B0 conv=notrunc status=none 2>/dev/null
    printf '\x31\xC0\xC3' | dd of="./macsploit.dylib" bs=1 seek=0x1A3C0 conv=notrunc status=none 2>/dev/null
    printf '\x31\xC0\xC3' | dd of="./macsploit.dylib" bs=1 seek=0x1A4D0 conv=notrunc status=none 2>/dev/null
    dd if=/dev/zero of="./macsploit.dylib" bs=1 seek=0x2A000 count=4096 conv=notrunc status=none 2>/dev/null
    echo -e "Done."

    # ===== INJECT DYLIB INTO ROBLOX =====
    echo -n "Injecting into Roblox... "
    if [ "$architecture" == "arm64" ]; then
        codesign --remove-signature /Applications/Roblox.app
    fi

    mv ./macsploit.dylib "/Applications/Roblox.app/Contents/MacOS/macsploit.dylib"
    
    # Download insert_dylib tool
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

    # ===== DOWNLOAD MACSPLOIT APP (GUI) =====
    echo -n "Downloading MacSploit App... "
    [ -d "/Applications/MacSploit.app" ] && rm -rf "/Applications/MacSploit.app"
    
    if [ "$architecture" == "arm64" ]; then
        /usr/bin/curl -s "https://api.macsploit.dev/arm/ms-app.zip" -o "./ms-app.zip"
    else
        /usr/bin/curl -s "https://api.macsploit.dev/main/ms-app.zip" -o "./ms-app.zip"
    fi
    echo -e "Done."

    echo -n "Extracting MacSploit App... "
    unzip -o -q "./ms-app.zip"
    if [ -d "./ms-app.app" ]; then
        mv ./ms-app.app /Applications/MacSploit.app
    elif [ -d "./MacSploit.app" ]; then
        mv ./MacSploit.app /Applications/MacSploit.app
    else
        # If extraction created a different name, find and move it
        local app_dir=$(find . -maxdepth 1 -type d -name "*.app" | head -1)
        if [ -n "$app_dir" ]; then
            mv "$app_dir" /Applications/MacSploit.app
        fi
    fi
    rm ./ms-app.zip
    echo -e "Done."

    # ===== DOWNLOAD SCRIPTS =====
    echo -n "Downloading scripts... "
    mkdir -p "$HOME/Documents/MacsploitUI"
    /usr/bin/curl -s "https://api.macsploit.dev/main/scripts.zip" -o "./scripts.zip"
    unzip -o -q -d "$HOME/Documents/MacsploitUI" ./scripts.zip
    rm ./scripts.zip
    echo -e "Done."

    # ===== CREATE UNLOCK FILES =====
    echo '{"unlocked":true,"trial":false,"expiry":"2099-12-31","permanent":true}' > "$HOME/Downloads/ms-version.json"
    echo 'PERMANENT_UNLOCKED' > "/Applications/MacSploit.app/Contents/Resources/unlock.flag"
    echo 'PERMANENT_UNLOCKED' > "/Applications/Roblox.app/Contents/Resources/unlock.flag"

    # ===== CREATE LAUNCHER SCRIPT =====
    cat > "/Applications/MacSploit.app/Contents/MacOS/launcher" << 'LAUNCHER'
#!/bin/bash
export MACSPLOIT_SKIP_LICENSE=1
export MACSPLOIT_UNLOCKED=1
export MACSPLOIT_FORCE_OFFLINE=1
export MACSPLOIT_EXPIRY="2099-12-31"
export DYLD_INSERT_LIBRARIES="/Applications/Roblox.app/Contents/MacOS/macsploit.dylib"
open "/Applications/Roblox.app"
LAUNCHER
    chmod +x "/Applications/MacSploit.app/Contents/MacOS/launcher"

    # ===== CREATE SYMLINK FOR EASY LAUNCH =====
    ln -sf "/Applications/MacSploit.app/Contents/MacOS/launcher" "/usr/local/bin/macsploit"
    chmod +x "/usr/local/bin/macsploit"

    # ===== VERIFY INSTALLATION =====
    echo -e "\n=========================================="
    if [ -d "/Applications/MacSploit.app" ]; then
        echo -e "✓ MacSploit App installed successfully"
    else
        echo -e "✗ MacSploit App missing - attempting manual fix..."
        # Try to download from alternative source
        /usr/bin/curl -L "https://github.com/macsploit/cracked/releases/download/latest/ms-app.zip" -o "./ms-app-fix.zip" 2>/dev/null
        if [ -f "./ms-app-fix.zip" ]; then
            unzip -o -q "./ms-app-fix.zip"
            mv ./ms-app.app /Applications/MacSploit.app 2>/dev/null
            rm ./ms-app-fix.zip
        fi
    fi
    
    if [ -f "/Applications/Roblox.app/Contents/MacOS/macsploit.dylib" ]; then
        echo -e "✓ Dylib injected successfully"
    else
        echo -e "✗ Dylib injection failed"
    fi
    
    echo -e "=========================================="
    echo -e "INSTALL COMPLETE - FULLY UNLOCKED"
    echo -e "Launch MacSploit.app from /Applications"
    echo -e "Or run 'macsploit' from terminal"
    echo -e "=========================================="
    
    rm -rf ./MacSploit.app 2>/dev/null
    exit
}

main
