#!/bin/bash
set -e

# ==============================================
#           VLESS WEBSOCKET GCP AUTO DEPLOYER
#                 created by prvtspyyy
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
    echo -e "${BOLD}${LRED}║${RESET}                    ${BOLD}${WHITE}VLESS REALITY GCP AUTO DEPLOYER${RESET}                       ${BOLD}${LRED}║${RESET}"
    echo -e "${BOLD}${LRED}║${RESET}                              ${CYAN}created by prvtspyyy${RESET}                             ${BOLD}${LRED}║${RESET}"
    echo -e "${BOLD}${LRED}║${RESET}                                                                                ${BOLD}${LRED}║${RESET}"
    echo -e "${BOLD}${LRED}╚══════════════════════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

rainbow_banner

# --- API Verification ---
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${C_PLAIN}$(math_bold "API VERIFICATION")${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"

REQUIRED_APIS=("run.googleapis.com" "containerregistry.googleapis.com" "cloudbuild.googleapis.com")
API_NAMES=("Cloud Run API" "Container Registry API" "Cloud Build API")

for i in "${!REQUIRED_APIS[@]}"; do
    API="${REQUIRED_APIS[$i]}"
    NAME="${API_NAMES[$i]}"
    echo -e "${C_INFO}[*]${RESET} Ensuring ${BOLD}${NAME}${RESET} is enabled..."
    gcloud services enable "${API}" --quiet 2>/dev/null
    echo -e "${C_SUCCESS}[✔]${RESET} ${NAME} ready"
done
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo ""

# --- Project Setup ---
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -z "$PROJECT_ID" ]; then
    PROJECT_ID="vless-$(date +%s)"
    gcloud projects create "$PROJECT_ID" --name="VLESS-Reality" --quiet
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

# --- CPU/RAM Selection ---
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${C_PLAIN}$(math_bold "CPU AND MEMORY")${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "  ${C_ACCENT}[1]${RESET} 1 vCPU, 1 GiB RAM"
echo -e "  ${C_ACCENT}[2]${RESET} 1 vCPU, 2 GiB RAM"
echo -e "  ${C_ACCENT}[3]${RESET} 2 vCPU, 2 GiB RAM"
read -p "$(echo -e "${C_INFO}[?]${RESET} Select [1-3]: ")" CHOICE
case $CHOICE in
    1) CPU="1"; MEMORY="1Gi" ;;
    2) CPU="1"; MEMORY="2Gi" ;;
    3) CPU="2"; MEMORY="2Gi" ;;
    *) CPU="1"; MEMORY="1Gi" ;;
esac
echo -e "${C_SUCCESS}[✔]${RESET} CPU: ${BOLD}${CPU}${RESET}, Memory: ${BOLD}${MEMORY}${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo ""

# ==============================================
#        CUSTOMIZABLE SERVICE NAME ONLY
# ==============================================
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${C_PLAIN}$(math_bold "SERVICE CONFIGURATION")${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"

# --- Customizable Service Name ---
DEFAULT_SERVICE_NAME="prvtspyyy404"
read -p "$(echo -e "${C_INFO}[?]${RESET} Enter service name [default: ${DEFAULT_SERVICE_NAME}]: ")" SERVICE_NAME_INPUT
SERVICE_NAME="${SERVICE_NAME_INPUT:-$DEFAULT_SERVICE_NAME}"
SERVICE_NAME=$(echo "$SERVICE_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
if [ -z "$SERVICE_NAME" ]; then
    SERVICE_NAME="$DEFAULT_SERVICE_NAME"
fi
echo -e "${C_SUCCESS}[✔]${RESET} Service name: ${BOLD}${SERVICE_NAME}${RESET}"

# --- Fixed Values ---
WS_PATH="/prvtspyyy404"
UUID="a3b7de87-b46f-4dcf-b6ed-5bf5ebe83167"

echo -e "${C_SUCCESS}[✔]${RESET} WebSocket path: ${BOLD}${WS_PATH}${RESET} (fixed)"
echo -e "${C_SUCCESS}[✔]${RESET} UUID: ${BOLD}${UUID}${RESET} (fixed)"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo ""

# --- Build and Deploy ---
IMAGE="gcr.io/$PROJECT_ID/$SERVICE_NAME:latest"

echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${C_PLAIN}$(math_bold "BUILDING AND DEPLOYING")${RESET}"
echo -e "${C_HEADER}════════════════════════════════════════════════════════════════════════════${RESET}"

echo -e "${C_INFO}[*]${RESET} Building container image..."
gcloud builds submit --tag "$IMAGE" . --quiet
echo -e "${C_SUCCESS}[✔]${RESET} Build complete"

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

SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" --region "$REGION" --format='value(status.url)' 2>/dev/null | sed 's|https://||')

# --- Automatic VLESS URI Generation ---
VLESS_URI="vless://${UUID}@${SERVICE_URL}:443?encryption=none&security=tls&type=ws&path=%2F${WS_PATH#/}#${SERVICE_NAME}"

echo ""
echo -e "${C_SUCCESS}╔════════════════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${C_SUCCESS}║${RESET}                                                                            ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${BOLD}${WHITE}$(math_bold "DEPLOYMENT SUCCESSFUL")${RESET}                                          ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}created by prvtspyyy404${RESET}                                           ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}║${RESET}                                                                            ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}╠════════════════════════════════════════════════════════════════════════════╣${RESET}"
echo -e "${C_SUCCESS}║${RESET}                                                                            ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}Service:${RESET}     ${BOLD}${SERVICE_NAME}${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}Address:${RESET}     ${BOLD}${SERVICE_URL}${RESET}"
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
echo -e "${C_SUCCESS}║${RESET}   ${BOLD}${VLESS_URI}${RESET}  ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}║${RESET}                                                                            ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}╚════════════════════════════════════════════════════════════════════════════╝${RESET}"
echo ""
