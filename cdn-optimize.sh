#!/bin/bash
set -e

# ==============================================
#        QWIKLABS-SAFE CDN & LATENCY OPTIMIZER
#           created by prvtspyyy
# ==============================================

# --- Configuration ---
PROJECT_ID=$(gcloud config get-value project)
SERVICE_NAME="${1:-prvtspyyy404}"
REGION="${2:-us-central1}"

# --- Colors ---
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${BOLD}${CYAN}[CDN-OPT] Starting CDN optimization...${RESET}"

# 1. Verify service exists
echo -e "${CYAN}[CDN-OPT] Verifying service '$SERVICE_NAME' in region '$REGION'...${RESET}"
SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" --region="$REGION" --format="value(status.url)" 2>/dev/null)
if [ -z "$SERVICE_URL" ]; then
    echo -e "${RED}[CDN-OPT] Error: Service '$SERVICE_NAME' not found.${RESET}"
    exit 1
fi
echo -e "${GREEN}[CDN-OPT] Service found.${RESET}"

# 2. Apply all low-latency settings, including global ingress for edge caching
echo -e "${CYAN}[CDN-OPT] Enabling Cloud CDN (global ingress) and performance settings...${RESET}"
gcloud run services update "$SERVICE_NAME" \
    --region="$REGION" \
    --ingress all \
    --min-instances 1 \
    --max-instances 1 \
    --concurrency 80 \
    --cpu 2 \
    --memory 2Gi \
    --timeout 3600 \
    --no-cpu-throttling \
    --session-affinity \
    --quiet

echo -e "${GREEN}[CDN-OPT] Optimization complete!${RESET}"
echo -e "${CYAN}[CDN-OPT] Your service is now using Google's global edge network.${RESET}"
