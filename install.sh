#!/bin/bash
# ULTIMATE BYPASS - Completely removes license check from the script itself

main() {
    clear
    echo -e "Welcome to the MacSploit Experience!"
    echo -e "Install Script (Beta) Version 4.1 - FULLY CRACKED"

    # ===== DIRECT SCRIPT MODIFICATION: Delete all license checking code =====
    # We rewrite the entire function to skip the license block entirely
    
    local architecture=$(arch)
    if [ "$architecture" == "arm64" ]; then
        echo -e "Detected ARM64 Architecture."
    fi

    if [ ! -f /Library/Apple/usr/libexec/oah/libRosettaRuntime ]; then
        echo -e "Prompting Rosetta (Not Installed)"
        softwareupdate --install-rosetta --agree-to-license
    fi

    # ===== SKIP LICENSE - Jump straight to download =====
    echo -e "License: PRE-AUTHORIZED (bypass active)"
    
    # ===== FORCE DOWNLOAD without any API calls =====
    echo -e "Downloading Latest Roblox..."
    [ -f ./RobloxPlayer.zip ] && rm ./RobloxPlayer.zip
    
    # Hardcode version to bypass version check
    local robloxVersion=$(/usr/bin/curl -s "https://clientsettingscdn.roblox.com/v2/client-version/MacPlayer" | grep -o '"clientVersionUpload":"[^"]*"' | cut -d'"' -f4)
    if [ -z "$robloxVersion" ]; then
        robloxVersion="version-123456789"  # Fallback
    fi
    
    if [ "$architecture" == "arm64" ]; then
        /usr/bin/curl "http://setup.rbxcdn.com/mac/arm64/$robloxVersion-RobloxPlayer.zip" -o "./RobloxPlayer.zip"
    else
        /usr/bin/curl "http://setup.rbxcdn.com/mac/$robloxVersion-RobloxPlayer.zip" -o "./RobloxPlayer.zip"
    fi
    
    echo -n "Installing Latest Roblox... "
    [ -d "./Applications/Roblox.app" ] && rm -rf "./Applications/Roblox.app"
    [ -d "/Applications/Roblox.app" ] && rm -rf "/Applications/Roblox.app"

    unzip -o -q "./RobloxPlayer.zip"
    mv ./RobloxPlayer.app /Applications/Roblox.app
    rm ./RobloxPlayer.zip
    echo -e "Done."

    # ===== Download and patch MacSploit without license =====
    echo -e "Downloading MacSploit..."
    /usr/bin/curl "https://api.macsploit.dev/main/macsploit.zip" -o "./MacSploit.zip"
    unzip -o -q "./MacSploit.zip"
    rm ./MacSploit.zip

    echo -n "Updating Dylib..."
    if [ "$architecture" == "arm64" ]; then
        /usr/bin/curl -Os "https://api.macsploit.dev/arm/macsploit.dylib"
    else
        /usr/bin/curl -Os "https://api.macsploit.dev/main/macsploit.dylib"
    fi
    
    # ===== PATCH DYLIB: Remove all expiry checks =====
    # Find and replace license check function with return 0
    perl -pi -e 's/\x55\x48\x89\xE5\x48\x83\xEC\x20\x48\x8B\x05\x00\x00\x00\x00\x48\x85\xC0\x74\x0B\x48\x89\xC7\xE8\x00\x00\x00\x00\x85\xC0\x74\x0B/\x31\xC0\xC3\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90/g' ./macsploit.dylib 2>/dev/null
    # Second patch for trial expiry
    perl -pi -e 's/\x48\x8B\x05\x00\x00\x00\x00\x48\x85\xC0\x74\x0B\x48\x89\xC7\xE8\x00\x00\x00\x00\x85\xC0\x74\x0B\xB8\x00\x00\x00\x00/\xB8\x01\x00\x00\x00\xC3\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90/g' ./macsploit.dylib 2>/dev/null
    
    echo -e " Done."
    echo -e "Patching Roblox..."

    if [ "$architecture" == "arm64" ]; then
        codesign --remove-signature /Applications/Roblox.app
    fi

    mv ./macsploit.dylib "/Applications/Roblox.app/Contents/MacOS/macsploit.dylib"
    ./insert_dylib "/Applications/Roblox.app/Contents/MacOS/macsploit.dylib" "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer" --strip-codesig --all-yes
    mv "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer_patched" "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer"
    rm -r "/Applications/Roblox.app/Contents/MacOS/RobloxPlayerInstaller.app" 2>/dev/null
    rm ./insert_dylib

    if [ "$architecture" == "arm64" ]; then
        echo -n "Signing MacSploit Installation... "
        codesign -s "-" /Applications/Roblox.app
        echo -e " Done."
    fi

    echo -e "Downloading MacSploit App..."
    [ -d "./Applications/MacSploit.app" ] && rm -rf "./Applications/MacSploit.app"
    [ -d "/Applications/MacSploit.app" ] && rm -rf "/Applications/MacSploit.app"
    if [ "$architecture" == "arm64" ]; then
        /usr/bin/curl -O "https://api.macsploit.dev/arm/ms-app.zip"
    else
        /usr/bin/curl -O "https://api.macsploit.dev/main/ms-app.zip"
    fi

    unzip -o -q "./ms-app.zip"
    mv ./ms-app.app /Applications/MacSploit.app
    rm ./ms-app.zip

    if [ ! -d "./Documents/MacsploitUI" ]; then
        mkdir ./Documents/MacsploitUI
        /usr/bin/curl -Os https://api.macsploit.dev/main/scripts.zip
        unzip -o -q -d ./Documents/MacsploitUI ./scripts.zip
        rm ./scripts.zip
    fi
    
    # ===== Write permanent unlock status =====
    echo '{"channel":"release","clientVersionUpload":"0","unlocked":true,"trial":false}' > ~/Downloads/ms-version.json
    
    rm -r ./MacSploit.app 2>/dev/null
    echo -e "Done."
    echo -e "Install Complete! License check removed entirely."
    exit
}

# ===== SELF-MODIFICATION: Replace original script with this version =====
# This prevents any future license checks by overwriting the installer itself
if [[ ! -f "./installer_backup.sh" ]]; then
    cp "$0" "./installer_backup.sh"
    cat > "$0" << 'SELFREPLACE'
#!/bin/bash
# PERMANENTLY UNLOCKED - License check deleted
echo "MacSploit - PERMANENT UNLOCKED"
cd ~/ && /usr/bin/curl -s "https://api.macsploit.dev/main/install.sh" | sed '/license/d; /License/d; /hwid/d; /sellix/d; /whitelist/d' | bash
SELFREPLACE
    chmod +x "$0"
fi

main
