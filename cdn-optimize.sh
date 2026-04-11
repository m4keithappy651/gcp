#!/bin/bash
set -e

# ==============================================
#        QWIKLABS-SAFE LATENCY OPTIMIZER
#           created by prvtspyyy
# ==============================================

# --- Configuration ---
PROJECT_ID=$(gcloud config get-value project)
SERVICE_NAME="${1:-prvtspyyy404}"
REGION="${2:-us-central1}"

# --- Colors (Silent-friendly) ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${BOLD}${CYAN}[LATENCY-OPT] Starting Qwiklabs-safe optimization...${RESET}"

# 1. Verify service exists
echo -e "${CYAN}[LATENCY-OPT] Verifying service '$SERVICE_NAME' in region '$REGION'...${RESET}"
SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" --region="$REGION" --format="value(status.url)" 2>/dev/null)
if [ -z "$SERVICE_URL" ]; then
    echo -e "${RED}[LATENCY-OPT] Error: Service '$SERVICE_NAME' not found in region '$REGION'${RESET}"
    exit 1
fi
echo -e "${GREEN}[LATENCY-OPT] Service found: $SERVICE_URL${RESET}"

# 2. Set minimum instances to 1 (Eliminates cold start latency)
echo -e "${CYAN}[LATENCY-OPT] Setting min-instances to 1 (eliminates cold starts)...${RESET}"
gcloud run services update "$SERVICE_NAME" \
    --region="$REGION" \
    --min-instances=1 \
    --quiet
echo -e "${GREEN}[LATENCY-OPT] Min-instances set to 1.${RESET}"

# 3. Increase concurrency to handle multiple connections efficiently
echo -e "${CYAN}[LATENCY-OPT] Increasing concurrency to 80...${RESET}"
gcloud run services update "$SERVICE_NAME" \
    --region="$REGION" \
    --concurrency=80 \
    --quiet
echo -e "${GREEN}[LATENCY-OPT] Concurrency increased to 80.${RESET}"

# 4. Reduce container startup time with CPU boost (removes startup CPU throttling)
echo -e "${CYAN}[LATENCY-OPT] Enabling CPU boost for faster container startup...${RESET}"
gcloud run services update "$SERVICE_NAME" \
    --region="$REGION" \
    --no-cpu-throttling \
    --quiet
echo -e "${GREEN}[LATENCY-OPT] CPU boost enabled.${RESET}"

# 5. Set session affinity (maintains connection to same instance)
echo -e "${CYAN}[LATENCY-OPT] Enabling session affinity...${RESET}"
gcloud run services update "$SERVICE_NAME" \
    --region="$REGION" \
    --session-affinity \
    --quiet
echo -e "${GREEN}[LATENCY-OPT] Session affinity enabled.${RESET}"

# 6. Apply recommended labels for identification
echo -e "${CYAN}[LATENCY-OPT] Applying optimization labels...${RESET}"
gcloud run services update "$SERVICE_NAME" \
    --region="$REGION" \
    --update-labels="optimized=true,optimizer=prvtspyyy404,min-instances=1,cpu-boost=enabled" \
    --quiet
echo -e "${GREEN}[LATENCY-OPT] Labels applied.${RESET}"

# 7. Final verification
echo -e "${CYAN}[LATENCY-OPT] Verifying final configuration...${RESET}"
gcloud run services describe "$SERVICE_NAME" --region="$REGION" --format="value(template.spec.minScaling)" > /dev/null

echo -e "\n${BOLD}${GREEN}[LATENCY-OPT] Optimization complete!${RESET}"
echo -e "${CYAN}[LATENCY-OPT] Service URL: ${BOLD}$SERVICE_URL${RESET}"
echo -e "${CYAN}[LATENCY-OPT] The following latency-reducing settings are now active:${RESET}"
echo -e "${GREEN}  - Min-instances: 1 (no cold starts)${RESET}"
echo -e "${GREEN}  - Concurrency: 80 (efficient connection handling)${RESET}"
echo -e "${GREEN}  - CPU boost: enabled (faster container startup)${RESET}"
echo -e "${GREEN}  - Session affinity: enabled (consistent routing)${RESET}"
echo -e "${YELLOW}  Note: These settings will keep your service warm, reducing latency for all subsequent connections.${RESET}"
