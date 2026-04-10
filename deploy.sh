#!/bin/bash
set -e

# ==============================================
#           VLESS GCP AUTO DEPLOYER
#              created by prvtspyyy
# ==============================================

# --- ANSI color & style definitions ---
BOLD='\033[1m'
RESET='\033[0m'

# Standard colors
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'

# Light (bright) colors
LRED='\033[1;31m'
LGREEN='\033[1;32m'
LYELLOW='\033[1;33m'
LBLUE='\033[1;34m'
LMAGENTA='\033[1;35m'
LCYAN='\033[1;36m'
LWHITE='\033[1;37m'

# Combined light+color
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

# --- Clear screen and display main banner ---
clear
echo ""
echo -e "${C_HEADER}╔════════════════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${C_HEADER}║${RESET}                                                                            ${C_HEADER}║${RESET}"
echo -e "${C_HEADER}║${RESET}   ${BOLD}${WHITE}$(math_bold "PRVTSPYYY404")${RESET}                                            ${C_HEADER}║${RESET}"
echo -e "${C_HEADER}║${RESET}   ${C_PLAIN}GOOGLE CLOUD PLATFORM VLESS AUTO DEPLOYER${RESET}                         ${C_HEADER}║${RESET}"
echo -e "${C_HEADER}║${RESET}   ${C_ACCENT}created by prvtspyyy${RESET}                                              ${C_HEADER}║${RESET}"
echo -e "${C_HEADER}║${RESET}                                                                            ${C_HEADER}║${RESET}"
echo -e "${C_HEADER}╚════════════════════════════════════════════════════════════════════════════╝${RESET}"
echo ""

# --- Function: Check and Enable APIs ---
check_enable_api() {
    local API=$1
    local DISPLAY_NAME=$2
    echo -e "${C_INFO}[*]${RESET} Checking ${BOLD}${DISPLAY_NAME}${RESET}..."
    if gcloud services list --enabled --filter="name:${API}" --format="value(name)" 2>/dev/null | grep -q "${API}"; then
        echo -e "${C_SUCCESS}[✔]${RESET} ${DISPLAY_NAME} already enabled"
    else
        echo -e "${C_WARN}[!]${RESET} Enabling ${DISPLAY_NAME}..."
        gcloud services enable "${API}" --quiet
        echo -e "${C_SUCCESS}[✔]${RESET} ${DISPLAY_NAME} enabled"
    fi
}

# --- Function: Fetch online regions only ---
get_online_regions() {
    # Get all regions that are UP and filter for those that support Cloud Run
    gcloud compute regions list --format="value(name)" --filter="status=UP" 2>/dev/null | while read -r reg; do
        # Check if region supports Cloud Run (run.googleapis.com)
        if gcloud run regions list --format="value(name)" 2>/dev/null | grep -qx "$reg"; then
            echo "$reg"
        fi
    done | sort
}

# --- Project Setup ---
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -z "$PROJECT_ID" ]; then
    echo -e "${C_WARN}[!]${RESET} No project set. Creating new project..."
    PROJECT_ID="vless-$(date +%s)"
    gcloud projects create "$PROJECT_ID" --name="VLESS-Proxy" --quiet
    gcloud config set project "$PROJECT_ID" --quiet
    echo -e "${C_SUCCESS}[✔]${RESET} Project created: ${BOLD}${PROJECT_ID}${RESET}"
else
    echo -e "${C_SUCCESS}[✔]${RESET} Using project: ${BOLD}${PROJECT_ID}${RESET}"
fi
echo ""

# --- Environment Verification ---
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${C_PLAIN}$(math_bold "ENVIRONMENT VERIFICATION")${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"

PROJECT_CHECK=$(gcloud config get-value project 2>/dev/null || echo "")
if [ -n "$PROJECT_CHECK" ]; then
    echo -e "${C_SUCCESS}[✔]${RESET} Project: ${BOLD}${PROJECT_CHECK}${RESET}"
else
    echo -e "${C_WARN}[!]${RESET} No project set"
fi

API_COUNT=$(gcloud services list --enabled --format="value(config.name)" 2>/dev/null | wc -l)
echo -e "${C_SUCCESS}[✔]${RESET} Enabled APIs: ${BOLD}${API_COUNT}${RESET} services"

DOCKER_VERSION=$(docker --version 2>/dev/null || echo "NOT FOUND")
if [[ "$DOCKER_VERSION" != "NOT FOUND" ]]; then
    echo -e "${C_SUCCESS}[✔]${RESET} Docker: ${BOLD}${DOCKER_VERSION}${RESET}"
else
    echo -e "${C_ERROR}[✘]${RESET} Docker not available"
    exit 1
fi
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo ""

# --- API Enablement ---
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${C_PLAIN}$(math_bold "ENABLING REQUIRED APIS")${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"

check_enable_api "run.googleapis.com" "Cloud Run API"
check_enable_api "containerregistry.googleapis.com" "Container Registry API"
check_enable_api "cloudbuild.googleapis.com" "Cloud Build API"
check_enable_api "compute.googleapis.com" "Compute Engine API"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo ""

# --- Region Selection (only online regions) ---
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${C_PLAIN}$(math_bold "REGION SELECTION")${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"

echo -e "${C_INFO}[*]${RESET} Fetching online Cloud Run regions..."
ONLINE_REGIONS=($(get_online_regions))

if [ ${#ONLINE_REGIONS[@]} -eq 0 ]; then
    echo -e "${C_ERROR}[✘]${RESET} No online regions found. Using fallback: us-central1"
    REGION="us-central1"
else
    echo -e "${C_SUCCESS}[✔]${RESET} Available regions (online & Cloud Run supported):"
    echo ""
    for i in "${!ONLINE_REGIONS[@]}"; do
        idx=$((i+1))
        if [ $idx -lt 10 ]; then
            echo -e "  ${C_ACCENT}[${idx}]${RESET}  ${BOLD}${ONLINE_REGIONS[$i]}${RESET}"
        else
            echo -e "  ${C_ACCENT}[${idx}]${RESET} ${BOLD}${ONLINE_REGIONS[$i]}${RESET}"
        fi
    done
    echo ""
    read -p "$(echo -e "${C_INFO}[?]${RESET} Select region [1-${#ONLINE_REGIONS[@]}]: ")" REGION_CHOICE
    if [[ "$REGION_CHOICE" =~ ^[0-9]+$ ]] && [ "$REGION_CHOICE" -ge 1 ] && [ "$REGION_CHOICE" -le ${#ONLINE_REGIONS[@]} ]; then
        REGION="${ONLINE_REGIONS[$((REGION_CHOICE-1))]}"
    else
        echo -e "${C_WARN}[!]${RESET} Invalid selection. Using us-central1"
        REGION="us-central1"
    fi
fi
echo -e "${C_SUCCESS}[✔]${RESET} Selected region: ${BOLD}${REGION}${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo ""

# --- CPU and RAM Selection ---
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${C_PLAIN}$(math_bold "CPU AND MEMORY CONFIGURATION")${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"

echo -e "${C_INFO}[*]${RESET} Select CPU and memory allocation:"
echo -e "  ${C_ACCENT}[1]${RESET} 1 vCPU, 1 GiB RAM"
echo -e "  ${C_ACCENT}[2]${RESET} 1 vCPU, 2 GiB RAM"
echo -e "  ${C_ACCENT}[3]${RESET} 2 vCPU, 2 GiB RAM"
echo -e "  ${C_ACCENT}[4]${RESET} 2 vCPU, 4 GiB RAM"
echo -e "  ${C_ACCENT}[5]${RESET} 4 vCPU, 4 GiB RAM"
read -p "$(echo -e "${C_INFO}[?]${RESET} Select configuration [1-5]: ")" CPU_RAM_CHOICE

case $CPU_RAM_CHOICE in
    1) CPU="1" MEMORY="1Gi" ;;
    2) CPU="1" MEMORY="2Gi" ;;
    3) CPU="2" MEMORY="2Gi" ;;
    4) CPU="2" MEMORY="4Gi" ;;
    5) CPU="4" MEMORY="4Gi" ;;
    *) CPU="1" MEMORY="1Gi" ; echo -e "${C_WARN}[!]${RESET} Invalid choice, using default" ;;
esac
echo -e "${C_SUCCESS}[✔]${RESET} CPU: ${BOLD}${CPU}${RESET}, Memory: ${BOLD}${MEMORY}${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo ""

# --- Build Parameters ---
UUID=$(grep -o '"id": "[^"]*' config.json | cut -d'"' -f4)
WS_PATH=$(grep -o '"path": "[^"]*' config.json | cut -d'"' -f4)
IMAGE="gcr.io/$PROJECT_ID/vless-ws:latest"

echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${C_PLAIN}$(math_bold "DEPLOYMENT PARAMETERS")${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${C_ACCENT}UUID:${RESET}     ${BOLD}${UUID}${RESET}"
echo -e "${C_ACCENT}WS Path:${RESET}   ${BOLD}${WS_PATH}${RESET}"
echo -e "${C_ACCENT}Region:${RESET}    ${BOLD}${REGION}${RESET}"
echo -e "${C_ACCENT}CPU:${RESET}       ${BOLD}${CPU}${RESET}"
echo -e "${C_ACCENT}Memory:${RESET}    ${BOLD}${MEMORY}${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo ""

# --- Build Docker Image ---
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${C_PLAIN}$(math_bold "BUILDING DOCKER IMAGE")${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${C_INFO}[*]${RESET} Building container image..."
docker build -t "$IMAGE" . --quiet
echo -e "${C_SUCCESS}[✔]${RESET} Build completed"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo ""

# --- Push to Container Registry ---
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${C_PLAIN}$(math_bold "PUSHING TO CONTAINER REGISTRY")${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${C_INFO}[*]${RESET} Pushing to gcr.io..."
docker push "$IMAGE" --quiet
echo -e "${C_SUCCESS}[✔]${RESET} Push completed"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo ""

# --- Deploy to Cloud Run with Public Access and Timeout ---
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${C_PLAIN}$(math_bold "DEPLOYING TO CLOUD RUN")${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${C_INFO}[*]${RESET} Deploying service with public access (timeout 3600s)..."

DEPLOY_OUTPUT=$(gcloud run deploy vless-ws \
    --image "$IMAGE" \
    --platform managed \
    --region "$REGION" \
    --allow-unauthenticated \
    --port 8080 \
    --cpu "$CPU" \
    --memory "$MEMORY" \
    --timeout 3600 \
    --quiet 2>&1)
DEPLOY_EXIT=$?

if [ $DEPLOY_EXIT -eq 0 ]; then
    echo -e "${C_SUCCESS}[✔]${RESET} Deployment successful"
else
    echo -e "${C_ERROR}[✘]${RESET} Deployment failed"
    echo ""
    echo -e "${C_WARN}════════════════════════════════════════════════════════════════════════════${RESET}"
    echo -e "${C_PLAIN}$(math_bold "TROUBLESHOOTING GUIDE")${RESET}"
    echo -e "${C_WARN}════════════════════════════════════════════════════════════════════════════${RESET}"
    if echo "$DEPLOY_OUTPUT" | grep -q "Quota exceeded"; then
        echo -e "${C_ERROR}[✘]${RESET} Quota exceeded in region ${REGION}"
        echo -e "${C_INFO}[→]${RESET} Solution: Choose a different region or request quota increase"
    elif echo "$DEPLOY_OUTPUT" | grep -q "FAILED_PRECONDITION"; then
        echo -e "${C_ERROR}[✘]${RESET} Organization policy violation (Domain Restricted Sharing)"
        echo -e "${C_INFO}[→]${RESET} Solution: Deploy as private or use personal GCP account"
        echo -e "${C_INFO}[→]${RESET} To deploy private: remove --allow-unauthenticated and configure IAM"
    elif echo "$DEPLOY_OUTPUT" | grep -q "Permission denied"; then
        echo -e "${C_ERROR}[✘]${RESET} Insufficient permissions"
        echo -e "${C_INFO}[→]${RESET} Solution: Ensure you have roles/run.admin and roles/iam.serviceAccountUser"
    else
        echo -e "${C_ERROR}[✘]${RESET} Unknown error. Check logs:"
        echo "$DEPLOY_OUTPUT"
    fi
    echo -e "${C_WARN}════════════════════════════════════════════════════════════════════════════${RESET}"
    exit 1
fi

# --- Retrieve Service URL ---
SERVICE_URL=$(gcloud run services describe vless-ws --region "$REGION" --format='value(status.url)' 2>/dev/null)
CLEAN_HOST=$(echo "$SERVICE_URL" | sed 's|https://||')
VLESS_URI="vless://${UUID}@${CLEAN_HOST}:443?encryption=none&security=tls&type=ws&path=${WS_PATH}#GCP-VLESS-PRVTSPYYY"

echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo ""

# --- Success Banner ---
echo -e "${C_SUCCESS}╔════════════════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${C_SUCCESS}║${RESET}                                                                            ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${BOLD}${WHITE}$(math_bold "DEPLOYMENT SUCCESSFUL")${RESET}                                          ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}created by prvtspyyy${RESET}                                              ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}║${RESET}                                                                            ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}╠════════════════════════════════════════════════════════════════════════════╣${RESET}"
echo -e "${C_SUCCESS}║${RESET}                                                                            ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}Address:${RESET}     ${BOLD}${CLEAN_HOST}${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}Port:${RESET}        ${BOLD}443${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}UUID:${RESET}        ${BOLD}${UUID}${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}WS Path:${RESET}     ${BOLD}${WS_PATH}${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}Transport:${RESET}   ${BOLD}WebSocket (ws)${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}TLS:${RESET}         ${BOLD}Enabled (Google Managed)${RESET}"
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
echo -e "${C_INFO}[i]${RESET} To change UUID or Path, edit config.json and redeploy."
echo -e "${C_INFO}[i]${RESET} Deployment created by prvtspyyy"
echo ""
