#!/bin/bash
set -e

# ==============================================
#           VLESS REALITY GCP AUTO DEPLOYER
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

# --- Service Name ---
SERVICE_NAME="vless-reality"
echo -e "${C_SUCCESS}[✔]${RESET} Service name: ${BOLD}${SERVICE_NAME}${RESET}"
echo ""

# --- Build Parameters ---
UUID=$(grep -o '"id": "[^"]*' config.json | cut -d'"' -f4)
IMAGE="gcr.io/$PROJECT_ID/vless-reality:latest"

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

# Deploy with HTTP/2 for gRPC
echo -e "${C_INFO}[*]${RESET} Deploying to Cloud Run..."
gcloud run deploy vless-ws \
    --image gcr.io/$PROJECT_ID/vless-ws \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated \
    --port 8080 \
    --cpu 1 \
    --memory 1Gi \
    --timeout 3600 \
    --quiet
    
SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" --region "$REGION" --format='value(status.url)' 2>/dev/null)
CLEAN_HOST=$(echo "$SERVICE_URL" | sed 's|https://||')

# --- Output ---
echo ""
echo -e "${C_SUCCESS}╔════════════════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${C_SUCCESS}║${RESET}                                                                            ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${BOLD}${WHITE}$(math_bold "DEPLOYMENT SUCCESSFUL")${RESET}                                          ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}created by prvtspyyy${RESET}                                              ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}║${RESET}                                                                            ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}╠════════════════════════════════════════════════════════════════════════════╣${RESET}"
echo -e "${C_SUCCESS}║${RESET}                                                                            ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}Protocol:${RESET}    ${BOLD}VLESS + Reality + gRPC${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}Address:${RESET}     ${BOLD}${CLEAN_HOST}${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}Port:${RESET}        ${BOLD}443${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}UUID:${RESET}        ${BOLD}${UUID}${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}ServiceName:${RESET}  ${BOLD}grpc${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}SNI:${RESET}         ${BOLD}www.microsoft.com${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}PublicKey:${RESET}   ${BOLD}OOKegkTMuYxL0oi6G_4nVzFdzor8XTcQ7sE4oZ9cVFU${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}ShortId:${RESET}     ${BOLD}6ba85179e30d4fc2${RESET}"
echo -e "${C_SUCCESS}║${RESET}   ${C_ACCENT}SpiderX:${RESET}     ${BOLD}/grpc${RESET}"
echo -e "${C_SUCCESS}║${RESET}                                                                            ${C_SUCCESS}║${RESET}"
echo -e "${C_SUCCESS}╚════════════════════════════════════════════════════════════════════════════╝${RESET}"
echo ""
