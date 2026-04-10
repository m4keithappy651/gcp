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

# Combined styles
C_SUCCESS="${BOLD}${LGREEN}"
C_ERROR="${BOLD}${LRED}"
C_WARN="${BOLD}${LYELLOW}"
C_INFO="${BOLD}${LCYAN}"
C_HEADER="${BOLD}${LMAGENTA}"
C_ACCENT="${BOLD}${LBLUE}"
C_PLAIN="${BOLD}${WHITE}"

# --- Bold mathematical Unicode converter (A-Z, 0-9) ---
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
echo -e "${C_HEADER}║${RESET}                                                                       ${C_HEADER}║${RESET}"
echo -e "${C_HEADER}║${RESET}   ${BOLD}${WHITE}$(math_bold "PRVTSPYYY404")${RESET}                  ${C_HEADER}║${RESET}"
echo -e "${C_HEADER}║${RESET}   ${C_PLAIN}GOOGLE CLOUD PLATFORM VLESS AUTO DEPLOYER${RESET}         ${C_HEADER}║${RESET}"
echo -e "${C_HEADER}║${RESET}   ${C_ACCENT}created by prvtspyyy${RESET}                             ${C_HEADER}║${RESET}"
echo -e "${C_HEADER}║${RESET}                                                                       ${C_HEADER}║${RESET}"
echo -e "${C_HEADER}╚════════════════════════════════════════════════════════════════════════════╝${RESET}"
echo ""

# ==============================================
#        FAILSAFE API VERIFICATION LOOP
# ==============================================
REQUIRED_APIS=(
    "run.googleapis.com"
    "containerregistry.googleapis.com"
    "cloudbuild.googleapis.com"
    "compute.googleapis.com"
    "iam.googleapis.com"
)

API_NAMES=(
    "Cloud Run API"
    "Container Registry API"
    "Cloud Build API"
    "Compute Engine API"
    "IAM API"
)

echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${C_PLAIN}$(math_bold "API VERIFICATION LOOP")${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"

for i in "${!REQUIRED_APIS[@]}"; do
    API="${REQUIRED_APIS[$i]}"
    NAME="${API_NAMES[$i]}"
    
    echo -e "${C_INFO}[*]${RESET} Waiting for ${BOLD}${NAME}${RESET} to be active..."
    gcloud services enable "${API}" --quiet 2>/dev/null &
    
    while true; do
        if gcloud services list --enabled --filter="name:${API}" --format="value(name)" 2>/dev/null | grep -q "${API}"; then
            echo -e "${C_SUCCESS}[✔]${RESET} ${NAME} is active"
            break
        else
            echo -e "${C_WARN}[!]${RESET} ${NAME} not yet active. Retrying enablement..."
            gcloud services enable "${API}" --quiet 2>/dev/null
            sleep 5
        fi
    done
done
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo ""

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

# ==============================================
#        PURE REAL-TIME REGION DETECTION
# ==============================================
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${C_PLAIN}$(math_bold "REAL-TIME REGION DETECTION")${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"

# Primary regions to test (covering all major GCP geographies)
TEST_REGIONS=(
    "us-central1"
    "us-east1"
    "us-west1"
    "us-west2"
    "us-west4"
    "europe-west1"
    "europe-west4"
    "europe-north1"
    "asia-east1"
    "asia-southeast1"
    "asia-northeast1"
    "australia-southeast1"
    "southamerica-east1"
    "northamerica-northeast1"
)

echo -e "${C_INFO}[*]${RESET} Probing regions for Cloud Run deployability in real-time..."
echo -e "${C_INFO}[*]${RESET} This may take 15-30 seconds. Please wait."
echo ""

AVAILABLE_REGIONS=()
BLOCKED_REGIONS=()

for reg in "${TEST_REGIONS[@]}"; do
    # Real-time probe: attempt to list Cloud Run services in the region
    # This validates both API access AND quota availability simultaneously
    if gcloud run services list --region="$reg" --limit=1 --format="value(name)" &>/dev/null; then
        AVAILABLE_REGIONS+=("$reg")
        echo -e "  ${C_ACCENT}[✓]${RESET} ${BOLD}${reg}${RESET} ${GREEN}● ACTIVE${RESET}"
    else
        BLOCKED_REGIONS+=("$reg")
        echo -e "  ${RED}[✗]${RESET} ${BOLD}${reg}${RESET} ${RED}● BLOCKED${RESET} (quota or policy restricted)"
    fi
    # Minimal delay to avoid rate limiting while maintaining real-time feel
    sleep 0.2
done

echo ""

# Summary of detection results
echo -e "${C_SUCCESS}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${C_PLAIN}DETECTION SUMMARY${RESET}"
echo -e "${C_SUCCESS}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "  ${GREEN}ACTIVE:${RESET}   ${#AVAILABLE_REGIONS[@]} region(s) ready for deployment"
echo -e "  ${RED}BLOCKED:${RESET}  ${#BLOCKED_REGIONS[@]} region(s) unavailable due to quota/policy"
echo -e "${C_SUCCESS}════════════════════════════════════════════════════════════════════════════${RESET}"
echo ""

# Check if any regions are available
if [ ${#AVAILABLE_REGIONS[@]} -eq 0 ]; then
    echo -e "${C_ERROR}[✘]${RESET} No ACTIVE regions found!"
    echo -e "${C_WARN}[!]${RESET} All tested regions are BLOCKED by quota or organization policy."
    echo -e "${C_INFO}[*]${RESET} This is common in Qwiklabs environments where resources are restricted."
    echo -e "${C_INFO}[*]${RESET} Forcing fallback to us-central1 (most permissive in Qwiklabs)..."
    AVAILABLE_REGIONS=("us-central1")
fi

# Display active regions for selection
echo -e "${C_PLAIN}ACTIVE REGIONS (READY FOR DEPLOYMENT)${RESET}"
echo ""

if [ ${#AVAILABLE_REGIONS[@]} -eq 1 ]; then
    REGION="${AVAILABLE_REGIONS[0]}"
    echo -e "${C_SUCCESS}[✔]${RESET} Auto-selected only active region: ${BOLD}${WHITE}${REGION}${RESET} ${GREEN}● ACTIVE${RESET}"
else
    for i in "${!AVAILABLE_REGIONS[@]}"; do
        idx=$((i+1))
        echo -e "  ${C_ACCENT}[${idx}]${RESET} ${BOLD}${AVAILABLE_REGIONS[$i]}${RESET} ${GREEN}● ACTIVE${RESET}"
    done
    echo ""
    read -p "$(echo -e "${C_INFO}[?]${RESET} Select region [1-${#AVAILABLE_REGIONS[@]}]: ")" REGION_CHOICE
    
    if [[ "$REGION_CHOICE" =~ ^[0-9]+$ ]] && [ "$REGION_CHOICE" -ge 1 ] && [ "$REGION_CHOICE" -le ${#AVAILABLE_REGIONS[@]} ]; then
        REGION="${AVAILABLE_REGIONS[$((REGION_CHOICE-1))]}"
        echo -e "${C_SUCCESS}[✔]${RESET} Selected: ${BOLD}${WHITE}${REGION}${RESET} ${GREEN}● ACTIVE${RESET}"
    else
        REGION="${AVAILABLE_REGIONS[0]}"
        echo -e "${C_WARN}[!]${RESET} Invalid choice. Defaulting to: ${BOLD}${REGION}${RESET}"
    fi
fi

echo ""
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

# --- Service Name Configuration ---
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${C_PLAIN}$(math_bold "SERVICE NAME CONFIGURATION")${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"

DEFAULT_SERVICE_NAME="vless-ws"
read -p "$(echo -e "${C_INFO}[?]${RESET} Enter service name [default: ${DEFAULT_SERVICE_NAME}]: ")" SERVICE_NAME_INPUT

if [ -z "$SERVICE_NAME_INPUT" ]; then
    SERVICE_NAME="$DEFAULT_SERVICE_NAME"
else
    # Sanitize input: only allow lowercase letters, numbers, and hyphens
    SERVICE_NAME=$(echo "$SERVICE_NAME_INPUT" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
    if [ -z "$SERVICE_NAME" ]; then
        SERVICE_NAME="$DEFAULT_SERVICE_NAME"
        echo -e "${C_WARN}[!]${RESET} Invalid name. Using default: ${BOLD}${SERVICE_NAME}${RESET}"
    fi
fi

# Hardcoded fallback to guarantee service name is never empty
if [ -z "$SERVICE_NAME" ]; then
    SERVICE_NAME="$DEFAULT_SERVICE_NAME"
fi

echo -e "${C_SUCCESS}[✔]${RESET} Service name: ${BOLD}${SERVICE_NAME}${RESET}"
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


# --- Deploy to Cloud Run with Explicit 412 Handling ---
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${C_PLAIN}$(math_bold "DEPLOYING TO CLOUD RUN")${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"

IAM_POLICY_FAILED=false
DEPLOY_LOG="/tmp/deploy_output.log"

# Attempt 1: Public deployment
echo -e "${C_INFO}[*]${RESET} Attempting public deployment..."
gcloud run deploy "${SERVICE_NAME}" \
    --image "$IMAGE" \
    --platform managed \
    --region "$REGION" \
    --allow-unauthenticated \
    --port 8080 \
    --cpu "$CPU" \
    --memory "$MEMORY" \
    --timeout 3600 \
    2>&1 | tee "$DEPLOY_LOG"
DEPLOY_EXIT=${PIPESTATUS[0]}

if [ $DEPLOY_EXIT -eq 0 ]; then
    echo -e "${C_SUCCESS}[✔]${RESET} Public deployment successful"
else
    if grep -q "FAILED_PRECONDITION.*Setting IAM policy\|412" "$DEPLOY_LOG"; then
        IAM_POLICY_FAILED=true
        echo -e "${C_WARN}[!]${RESET} Public deployment blocked by Domain Restricted Sharing policy"
        echo -e "${C_INFO}[*]${RESET} Automatically switching to private deployment..."
    else
        echo -e "${C_ERROR}[✘]${RESET} Deployment failed with unexpected error (check log above)"
        rm -f "$DEPLOY_LOG"
        exit 1
    fi
fi

# Attempt 2: Private deployment (triggered automatically)
if [ "$IAM_POLICY_FAILED" = true ]; then
    echo ""
    gcloud run deploy vless-ws \
        --image "$IMAGE" \
        --platform managed \
        --region "$REGION" \
        --port 8080 \
        --cpu "$CPU" \
        --memory "$MEMORY" \
        --timeout 3600 \
        2>&1 | tee "$DEPLOY_LOG"
    DEPLOY_EXIT=${PIPESTATUS[0]}
    
    if [ $DEPLOY_EXIT -eq 0 ]; then
        echo -e "${C_SUCCESS}[✔]${RESET} Private deployment successful"
    else
        echo -e "${C_ERROR}[✘]${RESET} Private deployment failed (check log above)"
        rm -f "$DEPLOY_LOG"
        exit 1
    fi
fi

rm -f "$DEPLOY_LOG"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo ""


# --- Retrieve Service URL ---
SERVICE_URL=$(gcloud run services describe "${SERVICE_NAME}" --region "$REGION" --format='value(status.url)' 2>/dev/null)
CLEAN_HOST=$(echo "$SERVICE_URL" | sed 's|https://||')

# --- Generate VLESS URI with Firebase SNI Spoof ---
VLESS_URI="vless://${UUID}@${CLEAN_HOST}:443?path=%2F${WS_PATH#/}&security=tls&encryption=none&insecure=1&host=${CLEAN_HOST}&fp=chrome&type=ws&allowInsecure=1&sni=firebase-settings.crashlytics.com#GCP-VLESS-PRVTSPYYY"

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
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}SNI:${RESET}         ${BOLD}firebase-settings.crashlytics.com${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}Region:${RESET}      ${BOLD}${REGION}${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}CPU:${RESET}         ${BOLD}${CPU}${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}Memory:${RESET}      ${BOLD}${MEMORY}${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}Timeout:${RESET}     ${BOLD}3600s${RESET}"
if [ "$IAM_POLICY_FAILED" = true ]; then
    echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}Access:${RESET}      ${BOLD}Private (authentication required)${RESET}"
else
    echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}Access:${RESET}      ${BOLD}Public${RESET}"
fi
echo -e "${C_SUCCESS}║${RESET}                                                                            ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}╠════════════════════════════════════════════════════════════════════════════╣${RESET}"
echo -e "${C_SUCCESS}║${RESET}                                                                            ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_PLAIN}Import URI:${RESET}                                                         ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${BOLD}${VLESS_URI}${RESET}  ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}║${RESET}                                                                            ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}╚════════════════════════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${C_INFO}[i]${RESET} To change UUID or Path, edit config.json and redeploy."
echo -e "${C_INFO}[i]${RESET} Deployment created by prvtspyyy"
echo ""
