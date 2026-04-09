#!/bin/bash
set -e

# ==============================================
#    𝗩 𝗟 𝗘 𝗦 𝗦  𝗚 𝗖 𝗣  𝗔 𝗨 𝗧 𝗢 𝗠 𝗔 𝗧 𝗘 𝗗
#              𝗖𝗿𝗲𝗮𝘁𝗲𝗱 𝗯𝘆 𝗽𝗿𝘃𝘁𝘀𝗽𝘆𝘆𝘆
#         𝘁.𝗺𝗲/𝗽𝗿𝘃𝘁𝘀𝗽𝘆  |  𝗺.𝗺𝗲/𝗽𝗿𝘃𝘁𝘀𝗽𝘆𝘆𝘆
# ==============================================

# ANSI Styles
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m'

clear
echo -e "${BOLD}${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║                                                            ║${NC}"
echo -e "${BOLD}${GREEN}║           ${WHITE}VLESS GCP AUTO DEPLOYER${GREEN}                           ║${NC}"
echo -e "${BOLD}${GREEN}║           ${CYAN}Created by prvtspyyy${GREEN}                              ║${NC}"
echo -e "${BOLD}${GREEN}║                                                            ║${NC}"
echo -e "${BOLD}${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# --- Function: Check and Enable APIs ---
check_enable_api() {
    local API=$1
    local DISPLAY_NAME=$2
    echo -e "${BOLD}${CYAN}[CHECK]${NC} Verifying ${YELLOW}${DISPLAY_NAME}${NC}..."
    if gcloud services list --enabled --filter="name:${API}" --format="value(name)" | grep -q "${API}"; then
        echo -e "        ${GREEN}✓ Already enabled${NC}"
    else
        echo -e "        ${YELLOW}⏳ Enabling ${DISPLAY_NAME}...${NC}"
        gcloud services enable "${API}" --quiet
        echo -e "        ${GREEN}✓ Enabled successfully${NC}"
    fi
}

# --- Project Setup ---
PROJECT_ID=$(gcloud config get-value project)
if [ -z "$PROJECT_ID" ]; then
    echo -e "${BOLD}${YELLOW}[SETUP]${NC} No project configured. Creating new project..."
    PROJECT_ID="vless-$(date +%s)"
    gcloud projects create "$PROJECT_ID" --name="VLESS-Proxy" --quiet
    gcloud config set project "$PROJECT_ID"
    echo -e "        ${GREEN}✓ Project created: ${BOLD}${PROJECT_ID}${NC}"
else
    echo -e "${BOLD}${CYAN}[PROJECT]${NC} Using existing project: ${BOLD}${WHITE}${PROJECT_ID}${NC}"
fi
echo ""

# --- API Verification and Auto-Enable ---
echo -e "${BOLD}${MAGENTA}════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${WHITE}              CHECKING REQUIRED SERVICES${NC}"
echo -e "${BOLD}${MAGENTA}════════════════════════════════════════════════════════════${NC}"
check_enable_api "run.googleapis.com" "Cloud Run API"
check_enable_api "containerregistry.googleapis.com" "Container Registry API"
check_enable_api "cloudbuild.googleapis.com" "Cloud Build API"
echo -e "${BOLD}${MAGENTA}════════════════════════════════════════════════════════════${NC}"
echo ""

# --- Build Parameters ---
UUID=$(grep -o '"id": "[^"]*' config.json | cut -d'"' -f4)
WS_PATH=$(grep -o '"path": "[^"]*' config.json | cut -d'"' -f4)
REGION="us-central1"
IMAGE="gcr.io/$PROJECT_ID/vless-ws:latest"

echo -e "${BOLD}${CYAN}[CONFIG]${NC} Deployment Parameters:"
echo -e "          ${YELLOW}UUID:${NC}     ${BOLD}${UUID}${NC}"
echo -e "          ${YELLOW}WS Path:${NC}   ${BOLD}${WS_PATH}${NC}"
echo -e "          ${YELLOW}Region:${NC}    ${BOLD}${REGION}${NC}"
echo ""

# --- Build Docker Image ---
echo -e "${BOLD}${MAGENTA}════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${WHITE}              BUILDING DOCKER IMAGE${NC}"
echo -e "${BOLD}${MAGENTA}════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}[BUILD]${NC} Building container image..."
docker build -t "$IMAGE" . --quiet
echo -e "         ${GREEN}✓ Build completed${NC}"
echo ""

# --- Push to Container Registry ---
echo -e "${BOLD}${MAGENTA}════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${WHITE}           PUSHING TO CONTAINER REGISTRY${NC}"
echo -e "${BOLD}${MAGENTA}════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}[PUSH]${NC} Uploading to Google Container Registry..."
docker push "$IMAGE" --quiet
echo -e "         ${GREEN}✓ Push completed${NC}"
echo ""

# --- Deploy to Cloud Run ---
echo -e "${BOLD}${MAGENTA}════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${WHITE}              DEPLOYING TO CLOUD RUN${NC}"
echo -e "${BOLD}${MAGENTA}════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}[DEPLOY]${NC} Creating Cloud Run service..."
gcloud run deploy vless-ws \
    --image "$IMAGE" \
    --platform managed \
    --region "$REGION" \
    --allow-unauthenticated \
    --port 8080 \
    --quiet

# --- Retrieve Service URL ---
SERVICE_URL=$(gcloud run services describe vless-ws --region "$REGION" --format='value(status.url)' 2>/dev/null)
CLEAN_HOST=$(echo "$SERVICE_URL" | sed 's|https://||')
VLESS_URI="vless://${UUID}@${CLEAN_HOST}:443?encryption=none&security=tls&type=ws&path=${WS_PATH}#GCP-VLESS-prvtspyyy"

echo ""
echo -e "${BOLD}${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║                                                            ║${NC}"
echo -e "${BOLD}${GREEN}║           ${WHITE}DEPLOYMENT SUCCESSFUL${GREEN}                              ║${NC}"
echo -e "${BOLD}${GREEN}║           ${CYAN}Created by prvtspyyy${GREEN}                              ║${NC}"
echo -e "${BOLD}${GREEN}║                                                            ║${NC}"
echo -e "${BOLD}${GREEN}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "${BOLD}${GREEN}║                                                            ║${NC}"
echo -e "${BOLD}${GREEN}║  ${YELLOW}Address:${NC}     ${BOLD}${WHITE}${CLEAN_HOST}${GREEN}${NC}"
echo -e "${BOLD}${GREEN}║  ${YELLOW}Port:${NC}        ${BOLD}${WHITE}443${GREEN}${NC}"
echo -e "${BOLD}${GREEN}║  ${YELLOW}UUID:${NC}        ${BOLD}${WHITE}${UUID}${GREEN}${NC}"
echo -e "${BOLD}${GREEN}║  ${YELLOW}WS Path:${NC}     ${BOLD}${WHITE}${WS_PATH}${GREEN}${NC}"
echo -e "${BOLD}${GREEN}║  ${YELLOW}Transport:${NC}   ${BOLD}${WHITE}WebSocket (ws)${GREEN}${NC}"
echo -e "${BOLD}${GREEN}║  ${YELLOW}TLS:${NC}         ${BOLD}${WHITE}Enabled (Google Managed)${GREEN}${NC}"
echo -e "${BOLD}${GREEN}║                                                            ║${NC}"
echo -e "${BOLD}${GREEN}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "${BOLD}${GREEN}║                                                            ║${NC}"
echo -e "${BOLD}${GREEN}║  ${CYAN}Import URI:${NC}                                             ${NC}"
echo -e "${BOLD}${GREEN}║  ${WHITE}${VLESS_URI}${GREEN}${NC}"
echo -e "${BOLD}${GREEN}║                                                            ║${NC}"
echo -e "${BOLD}${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}${YELLOW}[NOTE]${NC} Default UUID and Path are in config.json. Change them before redeploying."
echo ""
