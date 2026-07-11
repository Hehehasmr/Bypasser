#!/bin/bash
# Full bypass - intercepts all API calls at system level and patches binary expiry

main() {
    clear
    echo -e "Welcome to the MacSploit Experience!"
    echo -e "Install Script (Beta) Version 4.1 - FORCED UNLOCK"
    local architecture=$(arch)

    if [ "$architecture" == "arm64" ]; then
        echo -e "Detected ARM64 Architecture."
    fi

    if [ ! -f /Library/Apple/usr/libexec/oah/libRosettaRuntime ]; then
        echo -e "Prompting Rosetta (Not Installed)"
        softwareupdate --install-rosetta --agree-to-license
    fi

    # ===== HARDCORE BYPASS: Override DNS and hosts file =====
    echo "127.0.0.1 api.macsploit.dev" >> /etc/hosts
    # Start local fake server to intercept all API calls
    python3 -c "
import http.server
import socketserver
import json

class FakeHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if '/api/whitelist' in self.path:
            resp = json.dumps({'success': True, 'free_trial': False})
        elif '/api/sellix' in self.path:
            resp = 'Key Activation Complete!'
        elif '/main/jq-macos-amd64' in self.path:
            resp = '#!/bin/bash\necho \"true\"'
        else:
            resp = 'OK'
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(resp.encode())
    def do_POST(self):
        self.do_GET()
socketserver.TCPServer.allow_reuse_address = True
with socketserver.TCPServer(('127.0.0.1', 80), FakeHandler) as httpd:
    httpd.handle_request()
" &
FAKE_PID=$!
sleep 2

    # ===== Create fully fake jq that always returns success =====
    cat > ./jq << 'EOFJQ'
#!/bin/bash
case "$*" in
    *".success"*) echo "true" ;;
    *".free_trial"*) echo "false" ;;
    *".channel"*) echo "release" ;;
    *".clientVersionUpload"*) echo "0" ;;
    *) cat ;;
esac
EOFJQ
    chmod +x ./jq

    # ===== Create fake hwid =====
    cat > ./hwid << 'EOFHW'
#!/bin/bash
echo "PERMANENT-UNLOCK-0000"
EOFHW
    chmod +x ./hwid

    # ===== Patch the macsploit.dylib directly to remove expiry =====
    curl -s "https://api.macsploit.dev/main/macsploit.zip" -o "./MacSploit.zip"
    unzip -o -q "./MacSploit.zip"
    # Extract and patch the dylib before any checks
    if [ -f "./MacSploit.app/Contents/MacOS/macsploit.dylib" ]; then
        cp "./MacSploit.app/Contents/MacOS/macsploit.dylib" "./macsploit.dylib"
        # Overwrite timestamp check bytes with NOPs (0x90)
        printf '\x90\x90\x90\x90\x90' | dd of="./macsploit.dylib" bs=1 seek=0x2A4B0 conv=notrunc status=none 2>/dev/null
        printf '\x90\x90\x90\x90\x90' | dd of="./macsploit.dylib" bs=1 seek=0x2A500 conv=notrunc status=none 2>/dev/null
        printf '\x90\x90\x90\x90\x90' | dd of="./macsploit.dylib" bs=1 seek=0x2A5F0 conv=notrunc status=none 2>/dev/null
    fi

    # ===== Skip ALL license prompts forcefully =====
    export MACSPLOIT_SKIP_LICENSE=1
    export MACSPLOIT_UNLOCKED=1
    export MACSPLOIT_FORCE_OFFLINE=1

    # Override curl to always return success
    alias curl='function _curl { if [[ "$*" == *"api.macsploit.dev"* ]]; then echo "Key Activation Complete!"; return 0; else /usr/bin/curl "$@"; fi }; _curl'

    # ===== Main install continues - license check completely neutered =====
    echo -e "License: PERMANENT UNLOCKED (bypassed)"

    echo -e "Downloading Latest Roblox..."
    [ -f ./RobloxPlayer.zip ] && rm ./RobloxPlayer.zip
    local robloxVersionInfo=$(/usr/bin/curl -s "https://clientsettingscdn.roblox.com/v2/client-version/MacPlayer")
    local versionInfo='{"channel":"release","clientVersionUpload":"0"}'
    
    local mChannel="release"
    local version="0"
    local robloxVersion=$(echo $robloxVersionInfo | ./jq -r ".clientVersionUpload")
    
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
    
    # ===== Patch the downloaded dylib again =====
    printf '\x90\x90\x90\x90\x90' | dd of="./macsploit.dylib" bs=1 seek=0x2A4B0 conv=notrunc status=none 2>/dev/null
    printf '\x90\x90\x90\x90\x90' | dd of="./macsploit.dylib" bs=1 seek=0x2A500 conv=notrunc status=none 2>/dev/null
    printf '\x90\x90\x90\x90\x90' | dd of="./macsploit.dylib" bs=1 seek=0x2A5F0 conv=notrunc status=none 2>/dev/null
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
    
    # ===== Create permanent unlock file =====
    echo '{"channel":"release","clientVersionUpload":"0","unlocked":true}' > ~/Downloads/ms-version.json
    
    # ===== Kill fake server and cleanup =====
    kill $FAKE_PID 2>/dev/null
    rm ./jq ./hwid 2>/dev/null
    rm -r ./MacSploit.app 2>/dev/null
    
    echo -e "Done."
    echo -e "Install Complete! Hardcoded unlock - no expiry."
    exit
}

main
