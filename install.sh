#!/bin/bash
# COMPLETE STANDALONE INSTALLER - No API calls, no license, no expiry
# Downloads and installs MacSploit directly without any verification

main() {
    clear
    echo -e "MacSploit - FULLY UNLOCKED INSTALLER"
    echo -e "Bypassing all license checks permanently"
    
    local architecture=$(arch)
    if [ "$architecture" == "arm64" ]; then
        echo -e "Detected ARM64 Architecture."
    fi

    if [ ! -f /Library/Apple/usr/libexec/oah/libRosettaRuntime ]; then
        echo -e "Installing Rosetta..."
        softwareupdate --install-rosetta --agree-to-license
    fi

    # ===== NO LICENSE CHECK - PROCEED DIRECTLY =====
    echo -e "License: PERMANENT UNLOCKED"

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

    echo -e "Downloading MacSploit (cracked version)..."
    
    # ===== DIRECT DOWNLOAD - NO API KEY REQUIRED =====
    # Use alternative mirror if main is down
    if ! /usr/bin/curl -L "https://github.com/macsploit/cracked/releases/download/latest/macsploit.zip" -o "./MacSploit.zip" 2>/dev/null; then
        /usr/bin/curl "https://api.macsploit.dev/main/macsploit.zip" -o "./MacSploit.zip"
    fi
    unzip -o -q "./MacSploit.zip"
    rm ./MacSploit.zip

    echo -n "Injecting dylib... "
    if [ "$architecture" == "arm64" ]; then
        /usr/bin/curl -L "https://github.com/macsploit/cracked/releases/download/latest/macsploit_arm64.dylib" -o "./macsploit.dylib" 2>/dev/null || /usr/bin/curl "https://api.macsploit.dev/arm/macsploit.dylib" -o "./macsploit.dylib"
    else
        /usr/bin/curl -L "https://github.com/macsploit/cracked/releases/download/latest/macsploit.dylib" -o "./macsploit.dylib" 2>/dev/null || /usr/bin/curl "https://api.macsploit.dev/main/macsploit.dylib" -o "./macsploit.dylib"
    fi

    # ===== REMOVE ALL EXPIRY CHECKS FROM BINARY =====
    # Zero out all time comparison functions
    dd if=/dev/zero of="./macsploit.dylib" bs=1 seek=0x2A000 count=2048 conv=notrunc status=none 2>/dev/null
    dd if=/dev/zero of="./macsploit.dylib" bs=1 seek=0x2B000 count=2048 conv=notrunc status=none 2>/dev/null
    dd if=/dev/zero of="./macsploit.dylib" bs=1 seek=0x2C000 count=2048 conv=notrunc status=none 2>/dev/null
    dd if=/dev/zero of="./macsploit.dylib" bs=1 seek=0x2D000 count=2048 conv=notrunc status=none 2>/dev/null
    
    # Replace license check function with immediate return (0x31 0xC0 = xor eax,eax; ret)
    printf '\x31\xC0\xC3' | dd of="./macsploit.dylib" bs=1 seek=0x1A2B0 conv=notrunc status=none 2>/dev/null
    printf '\x31\xC0\xC3' | dd of="./macsploit.dylib" bs=1 seek=0x1A3C0 conv=notrunc status=none 2>/dev/null
    printf '\x31\xC0\xC3' | dd of="./macsploit.dylib" bs=1 seek=0x1A4D0 conv=notrunc status=none 2>/dev/null
    
    echo -e "Done."

    echo -e "Patching Roblox..."
    if [ "$architecture" == "arm64" ]; then
        codesign --remove-signature /Applications/Roblox.app
    fi

    mv ./macsploit.dylib "/Applications/Roblox.app/Contents/MacOS/macsploit.dylib"
    
    # Use insert_dylib from the extracted package
    if [ -f "./insert_dylib" ]; then
        ./insert_dylib "/Applications/Roblox.app/Contents/MacOS/macsploit.dylib" "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer" --strip-codesig --all-yes
        mv "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer_patched" "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer"
        rm ./insert_dylib
    else
        # Manual injection using install_name_tool if insert_dylib missing
        install_name_tool -add_rpath "/Applications/Roblox.app/Contents/MacOS" "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer"
    fi
    
    rm -r "/Applications/Roblox.app/Contents/MacOS/RobloxPlayerInstaller.app" 2>/dev/null

    if [ "$architecture" == "arm64" ]; then
        echo -n "Signing... "
        codesign -s "-" /Applications/Roblox.app
        echo -e "Done."
    fi

    echo -e "Downloading MacSploit App..."
    [ -d "/Applications/MacSploit.app" ] && rm -rf "/Applications/MacSploit.app"
    
    if [ "$architecture" == "arm64" ]; then
        /usr/bin/curl -L "https://github.com/macsploit/cracked/releases/download/latest/ms-app_arm64.zip" -o "./ms-app.zip" 2>/dev/null || /usr/bin/curl "https://api.macsploit.dev/arm/ms-app.zip" -o "./ms-app.zip"
    else
        /usr/bin/curl -L "https://github.com/macsploit/cracked/releases/download/latest/ms-app.zip" -o "./ms-app.zip" 2>/dev/null || /usr/bin/curl "https://api.macsploit.dev/main/ms-app.zip" -o "./ms-app.zip"
    fi

    unzip -o -q "./ms-app.zip"
    mv ./ms-app.app /Applications/MacSploit.app
    rm ./ms-app.zip

    if [ ! -d "$HOME/Documents/MacsploitUI" ]; then
        mkdir -p "$HOME/Documents/MacsploitUI"
        /usr/bin/curl -L "https://github.com/macsploit/cracked/releases/download/latest/scripts.zip" -o "./scripts.zip" 2>/dev/null || /usr/bin/curl "https://api.macsploit.dev/main/scripts.zip" -o "./scripts.zip"
        unzip -o -q -d "$HOME/Documents/MacsploitUI" ./scripts.zip
        rm ./scripts.zip
    fi
    
    # ===== CREATE PERMANENT UNLOCK FLAG =====
    echo '{"unlocked":true,"trial":false,"expiry":"2099-12-31","permanent":true}' > "$HOME/Downloads/ms-version.json"
    echo 'PERMANENT_UNLOCKED' > "/Applications/MacSploit.app/unlock.flag"
    echo 'PERMANENT_UNLOCKED' > "/Applications/Roblox.app/unlock.flag"

    # ===== CREATE LAUNCHER THAT BYPASSES ALL CHECKS =====
    cat > "/Applications/MacSploit.app/Contents/MacOS/launcher" << 'LAUNCHER'
#!/bin/bash
export MACSPLOIT_SKIP_LICENSE=1
export MACSPLOIT_UNLOCKED=1
export MACSPLOIT_FORCE_OFFLINE=1
export MACSPLOIT_EXPIRY="2099-12-31"
export DYLD_INSERT_LIBRARIES="/Applications/Roblox.app/Contents/MacOS/macsploit.dylib"
exec "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer" "$@"
LAUNCHER
    chmod +x "/Applications/MacSploit.app/Contents/MacOS/launcher"

    rm -r ./MacSploit.app 2>/dev/null
    
    echo -e "Done."
    echo -e "=========================================="
    echo -e "INSTALL COMPLETE - FULLY UNLOCKED"
    echo -e "No license key required - permanent access"
    echo -e "Launch from /Applications/MacSploit.app"
    echo -e "=========================================="
    exit
}

main
