#!/bin/bash
set -e

# ==============================================
#           VLESS WS TLS GCP AUTO DEPLOYER
#              created by prvtspyyy
# ==============================================

# --- ANSI color & style definitions ---
BOLD='\033[1m'
RESET='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
LRED='\033[1;31m'
LGREEN='\033[1;32m'
LYELLOW='\033[1;33m'
LBLUE='\033[1;34m'
LMAGENTA='\033[1;35m'
LCYAN='\033[1;36m'
LWHITE='\033[1;37m'

C_SUCCESS="${BOLD}${LGREEN}"
C_ERROR="${BOLD}${LRED}"
C_WARN="${BOLD}${LYELLOW}"
C_INFO="${BOLD}${LCYAN}"
C_HEADER="${BOLD}${LMAGENTA}"
C_ACCENT="${BOLD}${LBLUE}"
C_PLAIN="${BOLD}${WHITE}"

# --- Bold mathematical Unicode converter ---
math_bold() {
    echo "$1" | sed -e 's/A/𝗔/g' -e 's/B/𝗕/g' -e 's/C/𝗖/g' -e 's/D/𝗗/g' -e 's/E/𝗘/g' \
        -e 's/F/𝗙/g' -e 's/G/𝗚/g' -e 's/H/𝗛/g' -e 's/I/𝗜/g' -e 's/J/𝗝/g' \
        -e 's/K/𝗞/g' -e 's/L/𝗟/g' -e 's/M/𝗠/g' -e 's/N/𝗡/g' -e 's/O/𝗢/g' \
        -e 's/P/𝗣/g' -e 's/Q/𝗤/g' -e 's/R/𝗥/g' -e 's/S/𝗦/g' -e 's/T/𝗧/g' \
        -e 's/U/𝗨/g' -e 's/V/𝗩/g' -e 's/W/𝗪/g' -e 's/X/𝗫/g' -e 's/Y/𝗬/g' \
        -e 's/Z/𝗭/g' -e 's/0/𝟬/g' -e 's/1/𝟭/g' -e 's/2/𝟮/g' -e 's/3/𝟯/g' \
        -e 's/4/𝟰/g' -e 's/5/𝟱/g' -e 's/6/𝟲/g' -e 's/7/𝟳/g' -e 's/8/𝟴/g' \
        -e 's/9/𝟵/g'
}

# --- Rainbow Banner ---
rainbow_banner() {
    clear
    echo ""
    echo -e "${BOLD}${LRED}╔══════════════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${LRED}║${RESET}                                                                                ${BOLD}${LRED}║${RESET}"
    echo -ne "${BOLD}${LRED}║${RESET}     "
    echo -ne "${LRED}██████╗ ${LYELLOW}██████╗ ${LGREEN}██╗   ██╗${LCYAN}████████╗${LBLUE}███████╗${LMAGENTA}██████╗ ${LRED}██╗   ██╗${RESET}"
    echo -e "     ${BOLD}${LRED}║${RESET}"
    echo -ne "${BOLD}${LRED}║${RESET}     "
    echo -ne "${LRED}██╔══██╗${LYELLOW}██╔══██╗${LGREEN}██║   ██║${LCYAN}╚══██╔══╝${LBLUE}██╔════╝${LMAGENTA}╚════██╗${LRED}╚██╗ ██╔╝${RESET}"
    echo -e "     ${BOLD}${LRED}║${RESET}"
    echo -ne "${BOLD}${LRED}║${RESET}     "
    echo -ne "${LRED}██████╔╝${LYELLOW}██████╔╝${LGREEN}██║   ██║${LCYAN}   ██║   ${LBLUE}███████╗${LMAGENTA} █████╔╝ ${LRED} ╚████╔╝ ${RESET}"
    echo -e "     ${BOLD}${LRED}║${RESET}"
    echo -ne "${BOLD}${LRED}║${RESET}     "
    echo -ne "${LRED}██╔═══╝ ${LYELLOW}██╔══██╗${LGREEN}╚██╗ ██╔╝${LCYAN}   ██║   ${LBLUE}╚════██║${LMAGENTA} ╚═══██╗${LRED}   ╚██╔╝  ${RESET}"
    echo -e "     ${BOLD}${LRED}║${RESET}"
    echo -ne "${BOLD}${LRED}║${RESET}     "
    echo -ne "${LRED}██║     ${LYELLOW}██║  ██║${LGREEN} ╚████╔╝ ${LCYAN}   ██║   ${LBLUE}███████║${LMAGENTA}██████╔╝${LRED}   ██║   ${RESET}"
    echo -e "     ${BOLD}${LRED}║${RESET}"
    echo -ne "${BOLD}${LRED}║${RESET}     "
    echo -ne "${LRED}╚═╝     ${LYELLOW}╚═╝  ╚═╝${LGREEN}  ╚═══╝  ${LCYAN}   ╚═╝   ${LBLUE}╚══════╝${LMAGENTA}╚═════╝ ${LRED}   ╚═╝   ${RESET}"
    echo -e "     ${BOLD}${LRED}║${RESET}"
    echo -e "${BOLD}${LRED}║${RESET}                                                                                ${BOLD}${LRED}║${RESET}"
    echo -e "${BOLD}${LRED}║${RESET}                    ${BOLD}${WHITE}VLESS WS TLS GCP AUTO DEPLOYER${RESET}                       ${BOLD}${LRED}║${RESET}"
    echo -e "${BOLD}${LRED}║${RESET}                              ${CYAN}created by prvtspyyy${RESET}                             ${BOLD}${LRED}║${RESET}"
    echo -e "${BOLD}${LRED}║${RESET}                                                                                ${BOLD}${LRED}║${RESET}"
    echo -e "${BOLD}${LRED}╚══════════════════════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

rainbow_banner

# ==============================================
#        FAILSAFE API VERIFICATION
# ==============================================
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${C_PLAIN}$(math_bold "API VERIFICATION")${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"

REQUIRED_APIS=("run.googleapis.com" "containerregistry.googleapis.com" "cloudbuild.googleapis.com" "compute.googleapis.com")
API_NAMES=("Cloud Run API" "Container Registry API" "Cloud Build API" "Compute Engine API")

for i in "${!REQUIRED_APIS[@]}"; do
    API="${REQUIRED_APIS[$i]}"
    NAME="${API_NAMES[$i]}"
    echo -e "${C_INFO}[*]${RESET} Checking ${BOLD}${NAME}${RESET}..."
    
    # Check if API is already enabled
    if gcloud services list --enabled --filter="name:${API}" --format="value(name)" 2>/dev/null | grep -q "${API}"; then
        echo -e "${C_SUCCESS}[✔]${RESET} ${NAME} already enabled"
    else
        echo -e "${C_WARN}[!]${RESET} Enabling ${NAME}..."
        # Use || true to prevent set -e from killing script
        gcloud services enable "${API}" --quiet 2>/dev/null || true
        echo -e "${C_SUCCESS}[✔]${RESET} ${NAME} enablement requested"
    fi
done
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo ""

# --- Project Setup ---
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -z "$PROJECT_ID" ]; then
    PROJECT_ID="vless-$(date +%s)"
    gcloud projects create "$PROJECT_ID" --name="VLESS-WS-TLS" --quiet
    gcloud config set project "$PROJECT_ID" --quiet
fi
echo -e "${C_SUCCESS}[✔]${RESET} Project: ${BOLD}${PROJECT_ID}${RESET}"
echo ""

# --- Region Selection (Qwiklabs Optimized) ---
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${C_PLAIN}$(math_bold "REGION SELECTION")${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"

REGIONS=("us-central1" "us-east1" "us-west1" "europe-west1" "asia-east1" "asia-southeast1")
AVAILABLE_REGIONS=()

echo -e "${C_INFO}[*]${RESET} Probing regions for deployability..."
for reg in "${REGIONS[@]}"; do
    if gcloud run services list --region="$reg" --limit=1 &>/dev/null; then
        AVAILABLE_REGIONS+=("$reg")
        echo -e "  ${C_ACCENT}[✓]${RESET} ${BOLD}${reg}${RESET} ${GREEN}ACTIVE${RESET}"
    else
        echo -e "  ${RED}[✗]${RESET} ${BOLD}${reg}${RESET} ${RED}BLOCKED${RESET}"
    fi
    sleep 0.2
done

if [ ${#AVAILABLE_REGIONS[@]} -eq 0 ]; then
    echo -e "${C_WARN}[!]${RESET} No active regions. Using us-central1 as fallback."
    REGION="us-central1"
else
    REGION="${AVAILABLE_REGIONS[0]}"
    echo -e "${C_SUCCESS}[✔]${RESET} Auto-selected: ${BOLD}${REGION}${RESET}"
fi
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo ""

# --- Service Name Customization ---
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${C_PLAIN}$(math_bold "SERVICE CONFIGURATION")${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
DEFAULT_SERVICE_NAME="prvtspyyy-vless"
read -p "$(echo -e "${C_INFO}[?]${RESET} Enter service name [default: ${DEFAULT_SERVICE_NAME}]: ")" SERVICE_NAME_INPUT
SERVICE_NAME="${SERVICE_NAME_INPUT:-$DEFAULT_SERVICE_NAME}"
SERVICE_NAME=$(echo "$SERVICE_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
if [ -z "$SERVICE_NAME" ]; then
    SERVICE_NAME="$DEFAULT_SERVICE_NAME"
fi
echo -e "${C_SUCCESS}[✔]${RESET} Service name: ${BOLD}${SERVICE_NAME}${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo ""

# --- CPU/RAM Selection (Small to Large with Recommended) ---
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${C_PLAIN}$(math_bold "CPU AND MEMORY SELECTION")${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "  ${C_ACCENT}[1]${RESET} 1 vCPU, 1 GiB RAM"
echo -e "  ${C_ACCENT}[2]${RESET} 1 vCPU, 2 GiB RAM"
echo -e "  ${C_ACCENT}[3]${RESET} 2 vCPU, 2 GiB RAM"
echo -e "  ${C_ACCENT}[4]${RESET} 2 vCPU, 4 GiB RAM ${GREEN}(RECOMMENDED)${RESET}"
echo -e "  ${C_ACCENT}[5]${RESET} 4 vCPU, 8 GiB RAM"
read -p "$(echo -e "${C_INFO}[?]${RESET} Select configuration [1-5] [default: 4]: ")" CPU_RAM_CHOICE
case $CPU_RAM_CHOICE in
    1) CPU="1"; MEMORY="1Gi" ;;
    2) CPU="1"; MEMORY="2Gi" ;;
    3) CPU="2"; MEMORY="2Gi" ;;
    4) CPU="2"; MEMORY="4Gi" ;;
    5) CPU="4"; MEMORY="8Gi" ;;
    *) CPU="2"; MEMORY="4Gi" ; echo -e "${C_WARN}[!]${RESET} Invalid choice, using recommended (2 vCPU, 4 GiB)" ;;
esac
echo -e "${C_SUCCESS}[✔]${RESET} CPU: ${BOLD}${CPU}${RESET}, Memory: ${BOLD}${MEMORY}${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo ""

# --- Build Parameters ---
UUID=$(grep -o '"id": "[^"]*' config.json | cut -d'"' -f4)
WS_PATH=$(grep -o '"path": "[^"]*' config.json | cut -d'"' -f4)
IMAGE="gcr.io/$PROJECT_ID/$SERVICE_NAME:latest"

echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${C_PLAIN}$(math_bold "BUILDING AND DEPLOYING")${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"

# Build
echo -e "${C_INFO}[*]${RESET} Building Docker image..."
docker build -t "$IMAGE" . --quiet
echo -e "${C_SUCCESS}[✔]${RESET} Build complete"

# Push
echo -e "${C_INFO}[*]${RESET} Pushing to Container Registry..."
docker push "$IMAGE" --quiet
echo -e "${C_SUCCESS}[✔]${RESET} Push complete"

# Deploy
echo -e "${C_INFO}[*]${RESET} Deploying to Cloud Run..."
gcloud run deploy "$SERVICE_NAME" \
    --image "$IMAGE" \
    --platform managed \
    --region "$REGION" \
    --allow-unauthenticated \
    --port 8080 \
    --cpu "$CPU" \
    --memory "$MEMORY" \
    --timeout 3600 \
    --quiet

SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" --region "$REGION" --format='value(status.url)' 2>/dev/null)
CLEAN_HOST=$(echo "$SERVICE_URL" | sed 's|https://||')

# --- VLESS Connection Template ---
VLESS_URI="vless://${UUID}@${CLEAN_HOST}:443?encryption=none&security=tls&type=ws&path=%2F${WS_PATH#/}#${SERVICE_NAME}"

echo ""
echo -e "${C_SUCCESS}╔════════════════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${C_SUCCESS}║${RESET}                                                                            ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${BOLD}${WHITE}$(math_bold "DEPLOYMENT SUCCESSFUL")${RESET}                                          ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}created by prvtspyyy${RESET}                                              ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}║${RESET}                                                                            ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}╠════════════════════════════════════════════════════════════════════════════╣${RESET}"
echo -e "${C_SUCCESS}║${RESET}                                                                            ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}Service:${RESET}     ${BOLD}${SERVICE_NAME}${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}Address:${RESET}     ${BOLD}${CLEAN_HOST}${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}Port:${RESET}        ${BOLD}443${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}UUID:${RESET}        ${BOLD}${UUID}${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}WS Path:${RESET}     ${BOLD}${WS_PATH}${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}Transport:${RESET}   ${BOLD}WebSocket (ws)${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}Security:${RESET}    ${BOLD}TLS (Google Managed)${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}Region:${RESET}      ${BOLD}${REGION}${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}CPU:${RESET}         ${BOLD}${CPU}${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}Memory:${RESET}      ${BOLD}${MEMORY}${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}Timeout:${RESET}     ${BOLD}3600s${RESET}"
echo -e "${C_SUCCESS}║${RESET}                                                                            ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}╠════════════════════════════════════════════════════════════════════════════╣${RESET}"
echo -e "${C_SUCCESS}║${RESET}                                                                            ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_PLAIN}Import URI:${RESET}                                                         ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${VLESS_URI}  ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}║${RESET}                                                                            ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}╚════════════════════════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${C_INFO}[i]${RESET} Deployment Automation created by prvtspyyy"
SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" --region "$REGION" --format='value(status.url)' 2>/dev/null)
CLEAN_HOST=$(echo "$SERVICE_URL" | sed 's|https://||')
echo ""


# ==============================================
#        AUTOMATIC NETWORK MONITOR (BACKGROUND)
# ==============================================
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${C_PLAIN}$(math_bold "STARTING NETWORK MONITOR")${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"

# Check if network-monitor.sh exists and launch it in background
if [ -f "./network-monitor.sh" ]; then
    echo -e "${C_INFO}[*]${RESET} Launching network monitor in background..."
    chmod +x ./network-monitor.sh
    nohup ./network-monitor.sh "$SERVICE_NAME" "$REGION" > /dev/null 2>&1 &
    MONITOR_PID=$!
    echo -e "${C_SUCCESS}[✔]${RESET} Network monitor started (PID: $MONITOR_PID)"
    echo -e "${C_INFO}[*]${RESET} Logs will be saved to: ${BOLD}~/network-logs/${RESET}"
    echo -e "${C_INFO}[*]${RESET} To stop monitor: ${BOLD}kill $MONITOR_PID${RESET}"
else
    echo -e "${C_WARN}[!]${RESET} network-monitor.sh not found. Skipping."
    echo -e "${C_INFO}[*]${RESET} Add network-monitor.sh to your repository for automatic logging."
fi

echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo ""

# ==============================================
#        UNIFIED OUTPUT SELECTION BLOCK
#        QR + APP DEEP LINKS + FILE SAVE
# ==============================================
echo ""
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${C_PLAIN}$(math_bold "OUTPUT OPTIONS")${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo ""
echo -e "  ${C_ACCENT}[1]${RESET} Show QR Code (scan with phone)"
echo -e "  ${C_ACCENT}[2]${RESET} Generate Clickable Web Page"
echo -e "  ${C_ACCENT}[3]${RESET} Display Full URI (copy manually)"
echo -e "  ${C_ACCENT}[4]${RESET} Save to File"
echo -e "  ${C_ACCENT}[5]${RESET} ${BOLD}OPEN IN VPN APP (Auto-Import)${RESET}"
echo -e "  ${C_ACCENT}[6]${RESET} All Options"
echo -e "  ${C_ACCENT}[7]${RESET} Exit"
echo ""
read -p "$(echo -e "${C_INFO}[?]${RESET} Select output method [1-7]: ")" OUTPUT_CHOICE

# Encode VLESS URI for deep links
VLESS_BASE64=$(echo -n "$VLESS_URI" | base64 -w 0 2>/dev/null || echo -n "$VLESS_URI" | base64)

# --- Function: ASCII QR Code in Terminal ---
generate_ascii_qr() {
    echo ""
    echo -e "${C_INFO}[*]${RESET} Generating QR code..."
    
    if ! command -v qrencode &> /dev/null; then
        echo -e "${C_WARN}[!]${RESET} Installing qrencode (one-time)..."
        sudo apt-get update -qq && sudo apt-get install -y qrencode -qq 2>/dev/null || {
            echo -e "${C_ERROR}[✘]${RESET} Could not install qrencode."
            return 1
        }
    fi
    
    echo ""
    echo -e "${C_PLAIN}Scan this QR code with your VLESS client:${RESET}"
    echo ""
    echo "$VLESS_URI" | qrencode -t ANSIUTF8
    echo ""
    echo -e "${C_SUCCESS}[✔]${RESET} QR code displayed above"
}

# --- Function: Generate Web Page with QR + Clickable Link ---
generate_web_page() {
    mkdir -p /tmp/vless-preview
    cat > /tmp/vless-preview/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>VLESS Config - $SERVICE_NAME</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body { font-family: 'Segoe UI', sans-serif; padding: 20px; background: #0d1117; color: #c9d1d9; text-align: center; }
        .container { max-width: 600px; margin: 0 auto; }
        h2 { color: #00d4ff; }
        h3 { color: #8b949e; margin-top: 30px; }
        .btn { display: inline-block; background: #00d4ff; color: #0d1117; padding: 14px 28px; border-radius: 10px; text-decoration: none; font-weight: bold; font-size: 16px; margin: 10px 5px; }
        .btn:hover { background: #00b4d8; }
        .qr-container { background: white; padding: 20px; display: inline-block; border-radius: 12px; margin: 20px 0; }
        .info { background: #161b22; padding: 15px; border-radius: 8px; text-align: left; margin: 20px 0; word-break: break-all; }
        .info code { background: #0d1117; padding: 2px 6px; border-radius: 4px; color: #00d4ff; }
        .note { color: #8b949e; font-size: 14px; margin-top: 20px; }
        .section { margin: 30px 0; }
        hr { border: 1px solid #30363d; margin: 30px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h2>🚀 VLESS Configuration</h2>
        <p><strong>Service:</strong> $SERVICE_NAME</p>
        <p><strong>Address:</strong> $CLEAN_HOST</p>
        <p><strong>Port:</strong> 443 | <strong>Path:</strong> $WS_PATH</p>
        <p><strong>UUID:</strong> $UUID</p>
        
        <div class="qr-container">
            <img src="https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=$(echo -n "$VLESS_URI" | jq -sRr @uri 2>/dev/null || echo -n "$VLESS_URI" | sed 's/ /%20/g')" alt="QR Code" width="250" height="250">
            <p style="color: #0d1117; margin: 10px 0 0 0; font-weight: bold;">Scan with your phone</p>
        </div>
        
        <div class="info">
            <p><strong>📋 Full URI (click to copy):</strong></p>
            <code style="font-size: 12px;" onclick="navigator.clipboard.writeText('$VLESS_URI')">$VLESS_URI</code>
        </div>
        
        <hr>
        
        <h3>📱 Auto-Import to VPN Apps</h3>
        <p>Click an app below to auto-import (must have app installed):</p>
        
        <a href="netmod://import?url=${VLESS_BASE64}" class="btn">NetMod Syna</a>
        <a href="httpinjector://import?url=${VLESS_BASE64}" class="btn">HTTP Injector</a>
        <a href="httpcustom://import?url=${VLESS_BASE64}" class="btn">HTTP Custom</a>
        <a href="napsternetv://import?url=${VLESS_BASE64}" class="btn">NapsternetV</a>
        <a href="v2rayng://install-config?url=data:text/plain;base64,${VLESS_BASE64}" class="btn">v2rayNG</a>
        <a href="nekobox://import?v2ray=${VLESS_BASE64}" class="btn">Nekobox</a>
        <a href="streisand://import/${VLESS_BASE64}" class="btn">Streisand</a>
        <a href="hiddify://import/${VLESS_BASE64}" class="btn">Hiddify</a>
        <a href="karing://import?v2ray=${VLESS_BASE64}" class="btn">Karing</a>
        <a href="foxray://import?uri=${VLESS_BASE64}" class="btn">FoXray</a>
        <a href="shadowrocket://add/sub?type=vless&name=${SERVICE_NAME}&server=${CLEAN_HOST}&port=443&uuid=${UUID}&path=%2F${WS_PATH#/}&tls=1&allowInsecure=0" class="btn">Shadowrocket</a>
        
        <p class="note">Created by prvtspyyy</p>
    </div>
</body>
</html>
EOF

    # Kill existing server on port 8888
    fuser -k 8888/tcp 2>/dev/null || true
    
    # Start Python HTTP server
    cd /tmp/vless-preview && python3 -m http.server 8888 --bind 0.0.0.0 > /dev/null 2>&1 &
    SERVER_PID=$!
    
    echo ""
    echo -e "${C_SUCCESS}╔════════════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${C_SUCCESS}║${RESET}                    ${BOLD}${GREEN}WEB PAGE READY${RESET}                                      ${C_SUCCESS}║${RESET}"
    echo -e "${C_SUCCESS}╠════════════════════════════════════════════════════════════════════════════╣${RESET}"
    echo -e "${C_SUCCESS}║${RESET}  ${CYAN}1. Click Web Preview (eye icon) in Cloud Shell toolbar${RESET}             ${C_SUCCESS}║${RESET}"
    echo -e "${C_SUCCESS}║${RESET}  ${CYAN}2. Select port 8888${RESET}                                                 ${C_SUCCESS}║${RESET}"
    echo -e "${C_SUCCESS}║${RESET}  ${CYAN}3. Scan QR code OR click any VPN app button${RESET}                         ${C_SUCCESS}║${RESET}"
    echo -e "${C_SUCCESS}║${RESET}                                                                            ${C_SUCCESS}║${RESET}"
    echo -e "${C_SUCCESS}║${RESET}  ${YELLOW}Server PID: ${SERVER_PID}${RESET}                                             ${C_SUCCESS}║${RESET}"
    echo -e "${C_SUCCESS}╚════════════════════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    
    # Auto-cleanup after 10 minutes
    (sleep 600 && kill $SERVER_PID 2>/dev/null && rm -rf /tmp/vless-preview) &
}

# --- Function: App Deep Link Selection (Individual Apps) ---
app_deep_links() {
    echo ""
    echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
    echo -e "${C_PLAIN}$(math_bold "SELECT VPN APP TO AUTO-IMPORT")${RESET}"
    echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
    echo ""
    echo -e "  ${C_ACCENT}[1]${RESET} NetMod Syna"
    echo -e "  ${C_ACCENT}[2]${RESET} HTTP Injector"
    echo -e "  ${C_ACCENT}[3]${RESET} HTTP Custom"
    echo -e "  ${C_ACCENT}[4]${RESET} NapsternetV"
    echo -e "  ${C_ACCENT}[5]${RESET} v2rayNG"
    echo -e "  ${C_ACCENT}[6]${RESET} Nekobox"
    echo -e "  ${C_ACCENT}[7]${RESET} Streisand"
    echo -e "  ${C_ACCENT}[8]${RESET} Hiddify"
    echo -e "  ${C_ACCENT}[9]${RESET} Karing"
    echo -e "  ${C_ACCENT}[10]${RESET} Shadowrocket (iOS)"
    echo -e "  ${C_ACCENT}[11]${RESET} FoXray"
    echo -e "  ${C_ACCENT}[12]${RESET} Back to main menu"
    echo ""
    read -p "$(echo -e "${C_INFO}[?]${RESET} Select app [1-12]: ")" APP_CHOICE
    
    case $APP_CHOICE in
        1) DEEP_LINK="netmod://import?url=${VLESS_BASE64}"; APP_NAME="NetMod Syna" ;;
        2) DEEP_LINK="httpinjector://import?url=${VLESS_BASE64}"; APP_NAME="HTTP Injector" ;;
        3) DEEP_LINK="httpcustom://import?url=${VLESS_BASE64}"; APP_NAME="HTTP Custom" ;;
        4) DEEP_LINK="napsternetv://import?url=${VLESS_BASE64}"; APP_NAME="NapsternetV" ;;
        5) DEEP_LINK="v2rayng://install-config?url=data:text/plain;base64,${VLESS_BASE64}"; APP_NAME="v2rayNG" ;;
        6) DEEP_LINK="nekobox://import?v2ray=${VLESS_BASE64}"; APP_NAME="Nekobox" ;;
        7) DEEP_LINK="streisand://import/${VLESS_BASE64}"; APP_NAME="Streisand" ;;
        8) DEEP_LINK="hiddify://import/${VLESS_BASE64}"; APP_NAME="Hiddify" ;;
        9) DEEP_LINK="karing://import?v2ray=${VLESS_BASE64}"; APP_NAME="Karing" ;;
        10) DEEP_LINK="shadowrocket://add/sub?type=vless&name=${SERVICE_NAME}&server=${CLEAN_HOST}&port=443&uuid=${UUID}&path=%2F${WS_PATH#/}&tls=1&allowInsecure=0"; APP_NAME="Shadowrocket" ;;
        11) DEEP_LINK="foxray://import?uri=${VLESS_BASE64}"; APP_NAME="FoXray" ;;
        12) return ;;
        *) echo -e "${C_WARN}[!]${RESET} Invalid choice."; return ;;
    esac
    
    # Create individual app preview page
    mkdir -p /tmp/vless-preview
    cat > /tmp/vless-preview/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>${APP_NAME} - VLESS Import</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body { font-family: 'Segoe UI', sans-serif; padding: 20px; background: #0d1117; color: #c9d1d9; text-align: center; }
        .container { max-width: 500px; margin: 0 auto; }
        h2 { color: #00d4ff; }
        .btn { display: inline-block; background: #00d4ff; color: #0d1117; padding: 16px 32px; border-radius: 12px; text-decoration: none; font-weight: bold; font-size: 18px; margin: 20px 0; }
        .qr-container { background: white; padding: 20px; display: inline-block; border-radius: 12px; margin: 20px 0; }
        .info { background: #161b22; padding: 15px; border-radius: 8px; text-align: left; margin: 20px 0; word-break: break-all; }
        .note { color: #8b949e; font-size: 14px; margin-top: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <h2>🚀 ${APP_NAME} Auto-Import</h2>
        <p>Click the button below to automatically import your VLESS configuration.</p>
        
        <a href="${DEEP_LINK}" class="btn">🔥 OPEN IN ${APP_NAME}</a>
        
        <div class="qr-container">
            <img src="https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=$(echo -n "${DEEP_LINK}" | jq -sRr @uri 2>/dev/null || echo -n "${DEEP_LINK}")" alt="QR Code" width="200" height="200">
            <p style="color: #0d1117; margin: 10px 0 0 0;">Scan with your phone</p>
        </div>
        
        <div class="info">
            <p><strong>📋 Manual Copy:</strong></p>
            <code style="font-size: 12px;">${DEEP_LINK}</code>
        </div>
        
        <p class="note">Make sure ${APP_NAME} is installed.<br>Created by prvtspyyy</p>
    </div>
</body>
</html>
EOF

    fuser -k 8888/tcp 2>/dev/null || true
    cd /tmp/vless-preview && python3 -m http.server 8888 --bind 0.0.0.0 > /dev/null 2>&1 &
    SERVER_PID=$!
    
    echo ""
    echo -e "${C_SUCCESS}╔════════════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${C_SUCCESS}║${RESET}                    ${BOLD}${GREEN}${APP_NAME} IMPORT READY${RESET}                              ${C_SUCCESS}║${RESET}"
    echo -e "${C_SUCCESS}╠════════════════════════════════════════════════════════════════════════════╣${RESET}"
    echo -e "${C_SUCCESS}║${RESET}  ${CYAN}1. Click Web Preview (eye icon) → port 8888${RESET}                        ${C_SUCCESS}║${RESET}"
    echo -e "${C_SUCCESS}║${RESET}  ${CYAN}2. Click OPEN IN ${APP_NAME} or scan QR code${RESET}                        ${C_SUCCESS}║${RESET}"
    echo -e "${C_SUCCESS}║${RESET}                                                                            ${C_SUCCESS}║${RESET}"
    echo -e "${C_SUCCESS}║${RESET}  ${YELLOW}Server PID: ${SERVER_PID}${RESET}                                             ${C_SUCCESS}║${RESET}"
    echo -e "${C_SUCCESS}╚════════════════════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    
    (sleep 600 && kill $SERVER_PID 2>/dev/null && rm -rf /tmp/vless-preview) &
}

# --- Function: Display Full URI ---
display_uri() {
    echo ""
    echo -e "${C_PLAIN}╔════════════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${C_PLAIN}║${RESET}  ${BOLD}FULL VLESS URI (Triple-click to select all)${RESET}                          ${C_PLAIN}║${RESET}"
    echo -e "${C_PLAIN}╠════════════════════════════════════════════════════════════════════════════╣${RESET}"
    echo -e "${C_PLAIN}║${RESET}  ${VLESS_URI:0:70}${C_PLAIN}║${RESET}"
    if [ ${#VLESS_URI} -gt 70 ]; then
        echo -e "${C_PLAIN}║${RESET}  ${VLESS_URI:70:70}${C_PLAIN}║${RESET}"
    fi
    if [ ${#VLESS_URI} -gt 140 ]; then
        echo -e "${C_PLAIN}║${RESET}  ${VLESS_URI:140:70}${C_PLAIN}║${RESET}"
    fi
    echo -e "${C_PLAIN}╚════════════════════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

# --- Function: Save to File ---
save_to_file() {
    echo "$VLESS_URI" > /tmp/vless-uri.txt
    echo "$CLEAN_HOST" > /tmp/vless-host.txt
    echo "$UUID" > /tmp/vless-uuid.txt
    echo "$WS_PATH" > /tmp/vless-path.txt
    
    echo ""
    echo -e "${C_SUCCESS}[✔]${RESET} Configuration saved!"
    echo -e "${C_INFO}[*]${RESET} Copy URI: ${BOLD}cat /tmp/vless-uri.txt${RESET}"
    echo -e "${C_INFO}[*]${RESET} Copy Host: ${BOLD}cat /tmp/vless-host.txt${RESET}"
    echo -e "${C_INFO}[*]${RESET} Copy UUID: ${BOLD}cat /tmp/vless-uuid.txt${RESET}"
    echo -e "${C_INFO}[*]${RESET} Copy Path: ${BOLD}cat /tmp/vless-path.txt${RESET}"
}

# --- Process User Choice ---
case $OUTPUT_CHOICE in
    1)
        generate_ascii_qr
        ;;
    2)
        generate_web_page
        ;;
    3)
        display_uri
        ;;
    4)
        save_to_file
        ;;
    5)
        app_deep_links
        ;;
    6)
        generate_ascii_qr
        generate_web_page
        display_uri
        save_to_file
        ;;
    7)
        echo -e "${C_INFO}[*]${RESET} Exiting..."
        ;;
    *)
        echo -e "${C_WARN}[!]${RESET} Invalid choice. Displaying URI..."
        display_uri
        ;;
esac

# Always save to file as backup
echo "$VLESS_URI" > /tmp/vless-uri.txt

echo ""
echo -e "${C_SUCCESS}╔════════════════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${BOLD}${WHITE}$(math_bold "DEPLOYMENT COMPLETE")${RESET}                                            ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}created by prvtspyyy${RESET}                                              ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${CYAN}URI saved to: /tmp/vless-uri.txt${RESET}                                 ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}╚════════════════════════════════════════════════════════════════════════════╝${RESET}"
echo ""
