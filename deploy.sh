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

# ==============================================
#    POLICY-AWARE REGION FALLBACK
# ==============================================
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${C_PLAIN}$(math_bold "US-CENTRAL1 REGION DEPLOY")${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"

# Candidate regions ordered by likelihood of being allowed in Qwiklabs
CANDIDATE_REGIONS=("us-central1" "us-east1" "us-west1" "europe-west1" "asia-east1" "asia-southeast1")
SELECTED_REGION=""

for reg in "${CANDIDATE_REGIONS[@]}"; do
    echo -e "  ${C_INFO}[→]${RESET} Attempting deployment in ${reg}..."
    
    # Attempt a dry-run deployment to test policy compliance
    if gcloud run deploy --dry-run --region="$reg" --platform managed --port 8080 --cpu 1 --memory 1Gi --timeout 3600 --quiet &>/dev/null; then
        SELECTED_REGION="$reg"
        echo -e "  ${C_SUCCESS}[✔]${RESET} ${reg} is allowed by policy"
        break
    else
        echo -e "  ${C_WARN}[✘]${RESET} ${reg} is blocked by policy or quota"
    fi
    sleep 0.3
done

if [ -z "$SELECTED_REGION" ]; then
    echo -e "${C_ERROR}[✘]${RESET} No policy-compliant region found. Forcing us-central1 as last resort..."
    SELECTED_REGION="us-central1"
fi

REGION="$SELECTED_REGION"
echo -e "${C_SUCCESS}[✔]${RESET} Selected region: ${BOLD}${WHITE}${REGION}${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo ""

# Customizable service name
DEFAULT_SERVICE_NAME="prvtspyyy404"
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

# ==============================================
#        QUOTA-SAFE LOCAL BUILD & DEPLOY (NO TIMEOUT)
# ==============================================
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${C_PLAIN}$(math_bold "BUILDING AND DEPLOYING (QUOTA-FREE)")${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"

IMAGE="gcr.io/$PROJECT_ID/$SERVICE_NAME:latest"

# 1. Build the image locally to bypass Cloud Build quotas
echo -e "${C_INFO}[*]${RESET} Building container image locally..."
docker build -t "$IMAGE" . --quiet
echo -e "${C_SUCCESS}[✔]${RESET} Local build complete"

# 2. Push the image to Google Container Registry
echo -e "${C_INFO}[*]${RESET} Pushing image to Container Registry..."
docker push "$IMAGE" --quiet
echo -e "${C_SUCCESS}[✔]${RESET} Push complete"

# 3. Deploy to Cloud Run with all timeout and stability optimizations
echo -e "${C_INFO}[*]${RESET} Deploying to Cloud Run in ${REGION}..."
gcloud run deploy prvtspyyy-sg \
    --image gcr.io/$PROJECT_ID/prvtspyyy404:latest \
    --platform managed \
    --region asia-southeast1 \
    --allow-unauthenticated \
    --ingress all \
    --port 8080 \
    --cpu 1 \
    --memory 1Gi \
    --concurrency 80 \
    --timeout 3600 \
    --min-instances 1 \
    --max-instances 1 \
    --no-cpu-throttling \
    --session-affinity \
    --quiet

SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" --region "$REGION" --format='value(status.url)' 2>/dev/null)
CLEAN_HOST=$(echo "$SERVICE_URL" | sed 's|https://||')
echo -e "${C_SUCCESS}[✔]${RESET} Deployment complete"

# --- Generate VLESS URI with Custom Address and SNI ---
VLESS_URI="vless://${UUID}@client2.google.com:443?encryption=none&security=tls&type=ws&path=%2F${WS_PATH#/}&host=${CLEAN_HOST}&sni=firebase-settings.crashlytics.com&fp=chrome#${SERVICE_NAME}"
echo ""
echo -e "${C_SUCCESS}╔════════════════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${C_SUCCESS}║${RESET}                                                                            ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${BOLD}${WHITE}$(math_bold "DEPLOYMENT SUCCESSFUL")${RESET}                                          ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}created by prvtspyyy${RESET}                                              ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}║${RESET}                                                                            ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}╠════════════════════════════════════════════════════════════════════════════╣${RESET}"
echo -e "${C_SUCCESS}║${RESET}                                                                            ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}Service:${RESET}     ${BOLD}${SERVICE_NAME}${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}Address:${RESET}     ${BOLD}client2.google.com${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}SNI:${RESET}         ${BOLD}firebase-settings.crashlytics.com${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}Host:${RESET}        ${BOLD}${CLEAN_HOST}${RESET}"
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

gcloud run services describe $SERVICE_NAME --region asia-southeast1 --format='value(status.url)' | sed 's|https://||'

# ==============================================
#        INTERACTIVE OUTPUT SELECTION
# ==============================================
echo ""
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${C_PLAIN}$(math_bold "OUTPUT OPTIONS")${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo ""
echo -e "  ${C_ACCENT}[1]${RESET} Show QR Code (scan with phone)"
echo -e "  ${C_ACCENT}[2]${RESET} Generate Clickable Link (open in browser)"
echo -e "  ${C_ACCENT}[3]${RESET} Display Full URI (copy manually)"
echo -e "  ${C_ACCENT}[4]${RESET} Save to File (cat /tmp/vless-uri.txt)"
echo -e "  ${C_ACCENT}[5]${RESET} All of the above"
echo -e "  ${C_ACCENT}[6]${RESET} Exit"
echo ""
read -p "$(echo -e "${C_INFO}[?]${RESET} Select output method [1-6]: ")" OUTPUT_CHOICE

# --- Function: Generate QR Code ---
generate_qr() {
    echo ""
    echo -e "${C_INFO}[*]${RESET} Generating QR code..."
    
    # Install qrencode if not present
    if ! command -v qrencode &> /dev/null; then
        echo -e "${C_WARN}[!]${RESET} Installing qrencode (one-time)..."
        sudo apt-get update -qq && sudo apt-get install -y qrencode -qq 2>/dev/null || {
            echo -e "${C_ERROR}[✘]${RESET} Could not install qrencode. Use option 3 for URI."
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

# --- Function: Generate Clickable Link ---
generate_link() {
    # Save to HTML file
    cat > /tmp/vless-config.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>VLESS Config - $SERVICE_NAME</title>
    <meta charset="UTF-8">
    <style>
        body { font-family: monospace; padding: 20px; background: #1a1a2e; color: #eee; }
        h2 { color: #00d4ff; }
        .container { max-width: 800px; margin: 0 auto; }
        .field { background: #16213e; padding: 10px; margin: 10px 0; border-radius: 5px; }
        .label { color: #00d4ff; font-weight: bold; }
        textarea { width: 100%; padding: 10px; background: #0f3460; color: #fff; border: none; border-radius: 5px; font-family: monospace; }
        button { background: #00d4ff; color: #1a1a2e; border: none; padding: 10px 20px; border-radius: 5px; font-weight: bold; cursor: pointer; margin: 5px; }
        button:hover { background: #00b4d8; }
        .qr { text-align: center; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h2>🚀 VLESS Configuration - $SERVICE_NAME</h2>
        <p><strong>Created by prvtspyyy</strong></p>
        
        <div class="field">
            <span class="label">Full URI:</span><br>
            <textarea id="uri" rows="3" onclick="this.select()">$VLESS_URI</textarea>
            <button onclick="copyURI()">Copy URI</button>
        </div>
        
        <div class="field">
            <span class="label">Address:</span> $CLEAN_HOST
        </div>
        <div class="field">
            <span class="label">Port:</span> 443
        </div>
        <div class="field">
            <span class="label">UUID:</span> $UUID
        </div>
        <div class="field">
            <span class="label">Path:</span> $WS_PATH
        </div>
        <div class="field">
            <span class="label">Transport:</span> ws
        </div>
        <div class="field">
            <span class="label">TLS:</span> Enabled
        </div>
        
        <div class="qr">
            <img src="https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=$(echo -n "$VLESS_URI" | jq -sRr @uri)" alt="QR Code">
            <p>Scan with your phone</p>
        </div>
    </div>
    
    <script>
        function copyURI() {
            var textarea = document.getElementById('uri');
            textarea.select();
            navigator.clipboard.writeText(textarea.value);
            alert('URI copied to clipboard!');
        }
    </script>
</body>
</html>
EOF

    echo ""
    echo -e "${C_SUCCESS}[✔]${RESET} Configuration page created!"
    echo -e "${C_INFO}[*]${RESET} Starting web server on port 8888..."
    echo ""
    
    # Kill any existing server on port 8888
    fuser -k 8888/tcp 2>/dev/null || true
    
    # Start Python HTTP server in background
    cd /tmp && python3 -m http.server 8888 --bind 0.0.0.0 > /dev/null 2>&1 &
    SERVER_PID=$!
    
    # Generate Cloud Shell Web Preview URL
    WEB_PREVIEW_URL="https://shell.cloud.google.com/devshell/proxy?port=8888"
    
    echo -e "${C_PLAIN}╔════════════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${C_PLAIN}║${RESET}  ${BOLD}${GREEN}CLICKABLE LINK READY${RESET}                                                 ${C_PLAIN}║${RESET}"
    echo -e "${C_PLAIN}╠════════════════════════════════════════════════════════════════════════════╣${RESET}"
    echo -e "${C_PLAIN}║${RESET}  ${CYAN}Open this URL in your browser:${RESET}                                        ${C_PLAIN}║${RESET}"
    echo -e "${C_PLAIN}║${RESET}  ${BOLD}${WHITE}$WEB_PREVIEW_URL${RESET}${C_PLAIN}║${RESET}"
    echo -e "${C_PLAIN}║${RESET}                                                                            ${C_PLAIN}║${RESET}"
    echo -e "${C_PLAIN}║${RESET}  ${YELLOW}Press Ctrl+C here to stop the web server when done${RESET}                  ${C_PLAIN}║${RESET}"
    echo -e "${C_PLAIN}╚════════════════════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "${C_WARN}[!]${RESET} Server running in background (PID: $SERVER_PID)"
    echo -e "${C_INFO}[*]${RESET} To stop: ${BOLD}kill $SERVER_PID${RESET}"
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
        generate_qr
        ;;
    2)
        generate_link
        ;;
    3)
        display_uri
        ;;
    4)
        save_to_file
        ;;
    5)
        generate_qr
        generate_link
        display_uri
        save_to_file
        ;;
    6)
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
