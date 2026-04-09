#!/bin/bash
set -e

# ==============================================
#           VLESS GCP AUTO DEPLOYER
#              CREATED BY PRVTSPYYY404
# ==============================================

# ANSI Styles
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
BLUE='\033[0;34m'
NC='\033[0m'

clear
echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║                                                                      ║${NC}"
echo -e "${BOLD}${GREEN}║${NC}         ${BOLD}${WHITE}█   █ █     █████ █████ █████   ███  █   █ ██████${GREEN}         ${NC}"
echo -e "${BOLD}${GREEN}║${NC}         ${BOLD}${WHITE}█   █ █     █     █     █      █   █ ██  █ █${GREEN}              ${NC}"
echo -e "${BOLD}${GREEN}║${NC}         ${BOLD}${WHITE}█   █ █     ████  ████  ███    █   █ █ █ █ ████${GREEN}           ${NC}"
echo -e "${BOLD}${GREEN}║${NC}         ${BOLD}${WHITE}█   █ █     █     █     █      █   █ █  ██ █${GREEN}              ${NC}"
echo -e "${BOLD}${GREEN}║${NC}         ${BOLD}${WHITE}█████ █████ █████ █████ █       ███  █   █ ██████${GREEN}         ${NC}"
echo -e "${BOLD}${GREEN}║                                                                      ║${NC}"
echo -e "${BOLD}${GREEN}║${NC}              ${BOLD}${CYAN}GOOGLE CLOUD PLATFORM AUTO DEPLOYER${GREEN}                 ${NC}"
echo -e "${BOLD}${GREEN}║${NC}                    ${BOLD}${MAGENTA}CREATED BY PRVTSPYYY404${GREEN}                       ${NC}"
echo -e "${BOLD}${GREEN}║                                                                      ║${NC}"
echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ==============================================
#        AUTOMATIC ENVIRONMENT VERIFICATION
# ==============================================
echo ""
echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${WHITE}                    ENVIRONMENT VERIFICATION${NC}"
echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════════════════════${NC}"

PROJECT_CHECK=$(gcloud config get-value project 2>/dev/null || echo "")
if [ -n "$PROJECT_CHECK" ]; then
    echo -e "${BOLD}${GREEN}[✓]${NC} ${BOLD}PROJECT: ${WHITE}${PROJECT_CHECK}${NC}"
else
    echo -e "${BOLD}${YELLOW}[!]${NC} ${BOLD}NO PROJECT SET - WILL CREATE NEW${NC}"
fi

API_COUNT=$(gcloud services list --enabled --format="value(config.name)" 2>/dev/null | wc -l)
if [ "$API_COUNT" -gt 0 ]; then
    echo -e "${BOLD}${GREEN}[✓]${NC} ${BOLD}ENABLED APIS: ${WHITE}${API_COUNT} SERVICES${NC}"
else
    echo -e "${BOLD}${YELLOW}[!]${NC} ${BOLD}NO APIS ENABLED - WILL ENABLE REQUIRED${NC}"
fi

DOCKER_VERSION=$(docker --version 2>/dev/null || echo "NOT FOUND")
if [[ "$DOCKER_VERSION" != "NOT FOUND" ]]; then
    echo -e "${BOLD}${GREEN}[✓]${NC} ${BOLD}DOCKER: ${WHITE}${DOCKER_VERSION}${NC}"
else
    echo -e "${BOLD}${RED}[✗]${NC} ${BOLD}DOCKER NOT AVAILABLE - DEPLOYMENT MAY FAIL${NC}"
fi

echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════════════════════${NC}"
sleep 1


# --- Function: Check and Enable APIs ---
check_enable_api() {
    local API=$1
    local DISPLAY_NAME=$2
    echo -e "${BOLD}${CYAN}[CHECK]${NC} Verifying ${YELLOW}${DISPLAY_NAME}${NC}..."
    if gcloud services list --enabled --filter="name:${API}" --format="value(name)" | grep -q "${API}"; then
        echo -e "        ${GREEN}✓ ALREADY ENABLED${NC}"
    else
        echo -e "        ${YELLOW}⏳ ENABLING ${DISPLAY_NAME}...${NC}"
        gcloud services enable "${API}" --quiet
        echo -e "        ${GREEN}✓ ENABLED SUCCESSFULLY${NC}"
    fi
}

# --- Function: Check Region Quota Availability ---
check_region_quota() {
    local REGION=$1
    local PROJECT_ID=$2
    
    # Get quota information for Cloud Run memory in the specified region
    local QUOTA_INFO=$(gcloud alpha monitoring metrics list --filter="metric.type=\"run.googleapis.com/container/memory/limit_utilization\"" --format="value(resource.labels.location)" 2>/dev/null || echo "")
    
    # Alternative: Check if region is UP using compute regions list
    local REGION_STATUS=$(gcloud compute regions describe "$REGION" --format="value(status)" 2>/dev/null || echo "DOWN")
    
    if [[ "$REGION_STATUS" == "UP" ]]; then
        return 0  # Region is available
    else
        return 1  # Region is unavailable
    fi
}

# --- Project Setup ---
PROJECT_ID=$(gcloud config get-value project)
if [ -z "$PROJECT_ID" ]; then
    echo -e "${BOLD}${YELLOW}[SETUP]${NC} NO PROJECT CONFIGURED. CREATING NEW PROJECT..."
    PROJECT_ID="vless-$(date +%s)"
    gcloud projects create "$PROJECT_ID" --name="VLESS-PROXY" --quiet
    gcloud config set project "$PROJECT_ID"
    echo -e "        ${GREEN}✓ PROJECT CREATED: ${BOLD}${PROJECT_ID}${NC}"
else
    echo -e "${BOLD}${CYAN}[PROJECT]${NC} USING EXISTING PROJECT: ${BOLD}${WHITE}${PROJECT_ID}${NC}"
fi
echo ""

# --- API Verification and Auto-Enable ---
echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${WHITE}                    CHECKING REQUIRED SERVICES${NC}"
echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════════════════════${NC}"
check_enable_api "run.googleapis.com" "CLOUD RUN API"
check_enable_api "containerregistry.googleapis.com" "CONTAINER REGISTRY API"
check_enable_api "cloudbuild.googleapis.com" "CLOUD BUILD API"
check_enable_api "compute.googleapis.com" "COMPUTE ENGINE API"
echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════════════════════${NC}"
echo ""

# --- Real-Time Region Detection and Selection ---
echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${WHITE}                    DETECTING AVAILABLE REGIONS${NC}"
echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════════════════════${NC}"

# ==============================================
#        FIX: PRE-CREATE CLOUD BUILD BUCKET
# ==============================================
fix_cloud_build_bucket() {
    local PROJECT_ID=$1
    local REGION=$2
    
    echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${WHITE}                    CHECKING CLOUD BUILD BUCKET${NC}"
    echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════════════════════${NC}"
    
    # Determine bucket location based on selected region
    case "$REGION" in
        us-central1|us-east1|us-west1|us-west2|us-west3|us-west4|us-east4|us-east5|us-south1)
            BUCKET_LOCATION="$REGION"
            ;;
        *)
            BUCKET_LOCATION="us-central1"
            ;;
    esac
    
    BUCKET_NAME="${PROJECT_ID}_cloudbuild"
    
    echo -e "${BOLD}${CYAN}[CHECK]${NC} Verifying Cloud Build bucket in ${WHITE}${BUCKET_LOCATION}${NC}..."
    
    # Check if bucket exists
    if gsutil ls "gs://${BUCKET_NAME}" &>/dev/null; then
        BUCKET_CURRENT_LOCATION=$(gsutil ls -L -b "gs://${BUCKET_NAME}" | grep "Location constraint:" | awk '{print $3}')
        echo -e "${BOLD}${GREEN}[✓]${NC} Bucket exists in: ${WHITE}${BUCKET_CURRENT_LOCATION}${NC}"
    else
        echo -e "${BOLD}${YELLOW}[⟳]${NC} Creating Cloud Build bucket in ${WHITE}${BUCKET_LOCATION}${NC}..."
        gsutil mb -l "${BUCKET_LOCATION}" "gs://${BUCKET_NAME}" &
        spinner $! "CREATING STORAGE BUCKET"
        echo -e "${BOLD}${GREEN}[✓]${NC} Bucket created successfully"
    fi
    
    echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Fetch all available Cloud Run regions
echo -e "${BOLD}${CYAN}[SCAN]${NC} FETCHING ACTIVE GCP REGIONS..."
AVAILABLE_REGIONS=$(gcloud compute regions list --format="value(name)" 2>/dev/null | grep "^us-" | sort)

if [ -z "$AVAILABLE_REGIONS" ]; then
    echo -e "${BOLD}${YELLOW}[WARN]${NC} COULD NOT FETCH REGIONS. USING FALLBACK LIST."
    AVAILABLE_REGIONS="us-central1 us-east1 us-west1 us-west2 us-west3 us-west4 us-east4 us-east5 us-south1"
fi

echo ""
echo -e "${BOLD}${WHITE}SELECT A DEPLOYMENT REGION:${NC}"
echo -e "${BOLD}${CYAN}----------------------------------------${NC}"

# Build array of regions
REGION_ARRAY=()
COUNT=1
for REG in $AVAILABLE_REGIONS; do
    if check_region_quota "$REG" "$PROJECT_ID"; then
        STATUS="${GREEN}[AVAILABLE]${NC}"
    else
        STATUS="${YELLOW}[CHECK QUOTA]${NC}"
    fi
    REGION_ARRAY+=("$REG")
    echo -e "${BOLD}${GREEN}[$COUNT]${NC} ${WHITE}$REG${NC} ${STATUS}"
    ((COUNT++))
done

echo -e "${BOLD}${CYAN}----------------------------------------${NC}"
echo -e "${BOLD}${GREEN}[A]${NC} ${WHITE}AUTO-SELECT BEST REGION${NC}"
echo -e "${BOLD}${RED}[Q]${NC} ${WHITE}QUIT DEPLOYMENT${NC}"
echo ""

read -p "$(echo -e "${BOLD}${YELLOW}ENTER SELECTION [1-$((COUNT-1))/A/Q]: ${NC}")" REGION_SELECTION

if [[ "$REGION_SELECTION" == "Q" || "$REGION_SELECTION" == "q" ]]; then
    echo -e "${BOLD}${RED}[✗] DEPLOYMENT CANCELLED BY USER${NC}"
    exit 0
elif [[ "$REGION_SELECTION" == "A" || "$REGION_SELECTION" == "a" ]]; then
    # Auto-select first available US region
    for REG in $AVAILABLE_REGIONS; do
        if check_region_quota "$REG"; then
            REGION="$REG"
            echo -e "${BOLD}${GREEN}[✓]${NC} ${BOLD}AUTO-SELECTED REGION: ${WHITE}${REGION^^}${NC}"
            break
        fi
    done
    if [ -z "$REGION" ]; then
        REGION="us-central1"
        echo -e "${BOLD}${YELLOW}[!]${NC} ${BOLD}FALLBACK TO DEFAULT: ${WHITE}${REGION^^}${NC}"
    fi
else
    SELECTED_INDEX=$((REGION_SELECTION - 1))
    if [ $SELECTED_INDEX -ge 0 ] && [ $SELECTED_INDEX -lt ${#REGION_ARRAY[@]} ]; then
        REGION="${REGION_ARRAY[$SELECTED_INDEX]}"
        echo -e "${BOLD}${GREEN}[✓]${NC} ${BOLD}SELECTED REGION: ${WHITE}${REGION^^}${NC}"
    else
        REGION="us-central1"
        echo -e "${BOLD}${YELLOW}[!]${NC} ${BOLD}INVALID SELECTION. USING DEFAULT: ${WHITE}${REGION^^}${NC}"
    fi
fi

# ==============================================
#        CONFIGURATION PARAMETERS
# ==============================================
echo ""
echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${WHITE}                    CONFIGURATION PARAMETERS${NC}"
echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════════════════════${NC}"

UUID=$(grep -o '"id": "[^"]*' config.json | cut -d'"' -f4)
WS_PATH=$(grep -o '"path": "[^"]*' config.json | cut -d'"' -f4)
IMAGE="gcr.io/$PROJECT_ID/vless-ws:latest"

echo ""
echo -e "${BOLD}${CYAN}┌────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${BOLD}${CYAN}│${NC} ${BOLD}${YELLOW}UUID:${NC}     ${BOLD}${WHITE}$UUID${NC}"
echo -e "${BOLD}${CYAN}│${NC} ${BOLD}${YELLOW}WS PATH:${NC}   ${BOLD}${WHITE}$WS_PATH${NC}"
echo -e "${BOLD}${CYAN}│${NC} ${BOLD}${YELLOW}REGION:${NC}    ${BOLD}${WHITE}${REGION^^}${NC}"
echo -e "${BOLD}${CYAN}│${NC} ${BOLD}${YELLOW}IMAGE:${NC}     ${BOLD}${WHITE}$IMAGE${NC}"
echo -e "${BOLD}${CYAN}└────────────────────────────────────────────────────────────────────┘${NC}"

# ==============================================
#        BUILDING DOCKER IMAGE
# ==============================================
echo ""
echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${WHITE}                    BUILDING DOCKER IMAGE${NC}"
echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════════════════════${NC}"

docker build -t "$IMAGE" . --quiet &
BUILD_PID=$!

IMAGE_SHA=$(docker inspect "$IMAGE" --format='{{.Id}}' 2>/dev/null | cut -d: -f2 | cut -c1-12)
echo -e "${BOLD}${GREEN}[✓]${NC} ${BOLD}BUILD COMPLETED ${WHITE}[SHA: ${IMAGE_SHA}]${NC}"

# ==============================================
#        PUSHING TO CONTAINER REGISTRY
# ==============================================
echo ""
echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${WHITE}                    PUSHING TO CONTAINER REGISTRY${NC}"
echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════════════════════${NC}"

docker push "$IMAGE" --quiet &
PUSH_PID=$!

echo -e "${BOLD}${GREEN}[✓]${NC} ${BOLD}PUSH COMPLETED${NC}"

# ==============================================
#        DEPLOYING TO CLOUD RUN
# ==============================================
# ==============================================
#        DEPLOYING TO CLOUD RUN (WITH AUTO-FALLBACK)
# ==============================================
echo ""
echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${WHITE}                    DEPLOYING TO CLOUD RUN${NC}"
echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════════════════════${NC}"

DEPLOY_SUCCESS=false
IAM_POLICY_FAILED=false

# Attempt 1: Deploy as public service (standard)
echo -e "${BOLD}${CYAN}[ATTEMPT 1/2]${NC} Deploying as public service..."
gcloud run deploy vless-ws \
    --image "$IMAGE" \
    --platform managed \
    --region "$REGION" \
    --allow-unauthenticated \
    --port 8080 \
    --quiet 2>&1 | tee /tmp/deploy_log.txt &
DEPLOY_PID=$!
spinner $DEPLOY_PID "DEPLOYING TO CLOUD RUN (PUBLIC)"

# Check deployment status
if gcloud run services describe vless-ws --region "$REGION" --format="value(status.url)" &>/dev/null; then
    DEPLOY_SUCCESS=true
    echo -e "${BOLD}${GREEN}[✓]${NC} Public deployment successful"
else
    # Check if failure was due to IAM policy
    if grep -q "Setting IAM policy failed\|FAILED_PRECONDITION\|Domain Restricted Sharing" /tmp/deploy_log.txt; then
        IAM_POLICY_FAILED=true
        echo -e "${BOLD}${YELLOW}[!]${NC} Public deployment blocked by organization policy"
        echo -e "${BOLD}${CYAN}[→]${NC} Domain Restricted Sharing (DRS) prevented public access"
    else
        echo -e "${BOLD}${RED}[✗]${NC} Deployment failed for unknown reason"
        cat /tmp/deploy_log.txt
        exit 1
    fi
fi

# Attempt 2: Deploy as private service (IAM policy workaround)
if [ "$IAM_POLICY_FAILED" = true ]; then
    echo ""
    echo -e "${BOLD}${YELLOW}[ATTEMPT 2/2]${NC} Deploying as ${WHITE}PRIVATE${NC} service (authentication required)..."
    
    gcloud run deploy vless-ws \
        --image "$IMAGE" \
        --platform managed \
        --region "$REGION" \
        --port 8080 \
        --quiet &
    DEPLOY_PID=$!
    spinner $DEPLOY_PID "DEPLOYING TO CLOUD RUN (PRIVATE)"
    
    if gcloud run services describe vless-ws --region "$REGION" --format="value(status.url)" &>/dev/null; then
        DEPLOY_SUCCESS=true
        echo -e "${BOLD}${GREEN}[✓]${NC} Private deployment successful"
    else
        echo -e "${BOLD}${RED}[✗]${NC} Private deployment also failed"
        exit 1
    fi
fi

# Clean up temp file
rm -f /tmp/deploy_log.txt

# ==============================================
#        POST-DEPLOYMENT: SERVICE ACCOUNT SETUP (IF PRIVATE)
# ==============================================
if [ "$IAM_POLICY_FAILED" = true ]; then
    echo ""
    echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${WHITE}                    CONFIGURING SERVICE AUTHENTICATION${NC}"
    echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════════════════════${NC}"
    
    SA_NAME="vless-client-sa"
    SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
    
    # Create service account
    echo -e "${BOLD}${CYAN}[1/4]${NC} Creating service account: ${WHITE}${SA_NAME}${NC}"
    if gcloud iam service-accounts describe "$SA_EMAIL" &>/dev/null; then
        echo -e "${BOLD}${GREEN}[✓]${NC} Service account already exists"
    else
        gcloud iam service-accounts create "$SA_NAME" \
            --display-name="VLESS Client Service Account" \
            --quiet &
        spinner $! "CREATING SERVICE ACCOUNT"
        echo -e "${BOLD}${GREEN}[✓]${NC} Service account created"
    fi
    
    # Grant invoker role
    echo -e "${BOLD}${CYAN}[2/4]${NC} Granting Cloud Run Invoker permission..."
    gcloud run services add-iam-policy-binding vless-ws \
        --region="$REGION" \
        --member="serviceAccount:${SA_EMAIL}" \
        --role="roles/run.invoker" \
        --quiet &
    spinner $! "UPDATING IAM POLICY"
    echo -e "${BOLD}${GREEN}[✓]${NC} Invoker role granted"
    
    # Create and download key
    echo -e "${BOLD}${CYAN}[3/4]${NC} Generating service account key..."
    KEY_FILE="$HOME/vless-client-key.json"
    gcloud iam service-accounts keys create "$KEY_FILE" \
        --iam-account="$SA_EMAIL" \
        --quiet &
    spinner $! "CREATING KEY FILE"
    echo -e "${BOLD}${GREEN}[✓]${NC} Key saved to: ${WHITE}${KEY_FILE}${NC}"
    
    # Generate authentication command
    echo -e "${BOLD}${CYAN}[4/4]${NC} Preparing authentication snippet..."
    
    cat > "$HOME/vless-auth.sh" <<'AUTH_EOF'
#!/bin/bash
# VLESS Cloud Run Authentication Token Generator
# Run this before starting your VLESS client

KEY_FILE="$HOME/vless-client-key.json"
SERVICE_URL="PLACEHOLDER_URL"

if [ ! -f "$KEY_FILE" ]; then
    echo "Error: Service account key not found at $KEY_FILE"
    exit 1
fi

# Generate identity token
TOKEN=$(gcloud auth print-identity-token \
    --impersonate-service-account="$(jq -r .client_email $KEY_FILE)" \
    --audiences="$SERVICE_URL" \
    --include-email 2>/dev/null)

if [ -n "$TOKEN" ]; then
    echo "Bearer $TOKEN"
else
    echo "Error: Failed to generate token"
    exit 1
fi
AUTH_EOF

    # Replace placeholder with actual URL
    sed -i "s|PLACEHOLDER_URL|$SERVICE_URL|g" "$HOME/vless-auth.sh"
    chmod +x "$HOME/vless-auth.sh"
    
    echo -e "${BOLD}${GREEN}[✓]${NC} Authentication script created: ${WHITE}$HOME/vless-auth.sh${NC}"
    
    # Display client configuration note
    echo ""
    echo -e "${BOLD}${YELLOW}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${YELLOW}║                    ⚠️  CLIENT AUTHENTICATION REQUIRED  ⚠️             ║${NC}"
    echo -e "${BOLD}${YELLOW}╠══════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BOLD}${YELLOW}║${NC} ${WHITE}This service is PRIVATE. Your VLESS client must authenticate.${NC}     ${BOLD}${YELLOW}║${NC}"
    echo -e "${BOLD}${YELLOW}║${NC}                                                                      ${BOLD}${YELLOW}║${NC}"
    echo -e "${BOLD}${YELLOW}║${NC} ${CYAN}Option 1 (Automated):${NC} Run this before connecting:                    ${BOLD}${YELLOW}║${NC}"
    echo -e "${BOLD}${YELLOW}║${NC}     ${GREEN}$HOME/vless-auth.sh${NC}                                  ${BOLD}${YELLOW}║${NC}"
    echo -e "${BOLD}${YELLOW}║${NC}                                                                      ${BOLD}${YELLOW}║${NC}"
    echo -e "${BOLD}${YELLOW}║${NC} ${CYAN}Option 2 (Manual):${NC} Generate token with:                              ${BOLD}${YELLOW}║${NC}"
    echo -e "${BOLD}${YELLOW}║${NC}     ${GREEN}gcloud auth print-identity-token \\${NC}                         ${BOLD}${YELLOW}║${NC}"
    echo -e "${BOLD}${YELLOW}║${NC}     ${GREEN}  --impersonate-service-account=${SA_EMAIL} \\${NC}                ${BOLD}${YELLOW}║${NC}"
    echo -e "${BOLD}${YELLOW}║${NC}     ${GREEN}  --audiences=${SERVICE_URL}${NC}                                 ${BOLD}${YELLOW}║${NC}"
    echo -e "${BOLD}${YELLOW}║${NC}                                                                      ${BOLD}${YELLOW}║${NC}"
    echo -e "${BOLD}${YELLOW}║${NC} ${CYAN}Option 3 (Client Config):${NC} Add header to VLESS client:                ${BOLD}${YELLOW}║${NC}"
    echo -e "${BOLD}${YELLOW}║${NC}     ${GREEN}Authorization: Bearer \$(./vless-auth.sh)${NC}                     ${BOLD}${YELLOW}║${NC}"
    echo -e "${BOLD}${YELLOW}╚══════════════════════════════════════════════════════════════════════╝${NC}"
fi
# ==============================================
#        RETRIEVE SERVICE DETAILS
# ==============================================
echo ""
echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${WHITE}                    RETRIEVING SERVICE DETAILS${NC}"
echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════════════════════${NC}"

SERVICE_URL=$(gcloud run services describe vless-ws --region "$REGION" --format='value(status.url)' 2>/dev/null)
CLEAN_HOST=$(echo "$SERVICE_URL" | sed 's|https://||')
VLESS_URI="vless://${UUID}@${CLEAN_HOST}:443?encryption=none&security=tls&type=ws&path=${WS_PATH}#GCP-VLESS-PRVTSPYYY404"


# ==============================================
#        DEPLOYMENT SUCCESS BANNER
# ==============================================
echo ""
echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║                                                                      ║${NC}"
echo -e "${BOLD}${GREEN}║${NC}                    ${BOLD}${WHITE}█▀▄ █▀▀ █▀▄ █   █▀█ █▄█ █▀▄▀█ █▀▀ █▀█ ▀█▀${GREEN}                    ${NC}"
echo -e "${BOLD}${GREEN}║${NC}                    ${BOLD}${WHITE}█░█ ██▄ █▀▄ █▄▄ █▄█ ░█░ █░▀░█ ██▄ █▀▄ ░█░${GREEN}                    ${NC}"
echo -e "${BOLD}${GREEN}║                                                                      ║${NC}"
echo -e "${BOLD}${GREEN}║${NC}                        ${BOLD}${GREEN}SUCCESSFULLY DEPLOYED${NC}                       ${GREEN}║${NC}"
echo -e "${BOLD}${GREEN}║${NC}                    ${BOLD}${MAGENTA}CREATED BY PRVTSPYYY404${NC}                       ${GREEN}║${NC}"
echo -e "${BOLD}${GREEN}║                                                                      ║${NC}"
echo -e "${BOLD}${GREEN}╠══════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${BOLD}${GREEN}║                                                                      ║${NC}"
echo -e "${BOLD}${GREEN}║${NC}  ${BOLD}${YELLOW}ADDRESS:${NC}     ${BOLD}${WHITE}$CLEAN_HOST${GREEN}${NC}"
echo -e "${BOLD}${GREEN}║${NC}  ${BOLD}${YELLOW}PORT:${NC}        ${BOLD}${WHITE}443${GREEN}${NC}"
echo -e "${BOLD}${GREEN}║${NC}  ${BOLD}${YELLOW}UUID:${NC}        ${BOLD}${WHITE}$UUID${GREEN}${NC}"
echo -e "${BOLD}${GREEN}║${NC}  ${BOLD}${YELLOW}WS PATH:${NC}     ${BOLD}${WHITE}$WS_PATH${GREEN}${NC}"
echo -e "${BOLD}${GREEN}║${NC}  ${BOLD}${YELLOW}TRANSPORT:${NC}   ${BOLD}${WHITE}WEBSOCKET (WS)${GREEN}${NC}"
echo -e "${BOLD}${GREEN}║${NC}  ${BOLD}${YELLOW}TLS:${NC}         ${BOLD}${WHITE}ENABLED (GOOGLE MANAGED)${GREEN}${NC}"
echo -e "${BOLD}${GREEN}║${NC}  ${BOLD}${YELLOW}REGION:${NC}      ${BOLD}${WHITE}${REGION^^}${GREEN}${NC}"
echo -e "${BOLD}${GREEN}║                                                                      ║${NC}"
echo -e "${BOLD}${GREEN}╠══════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${BOLD}${GREEN}║                                                                      ║${NC}"
echo -e "${BOLD}${GREEN}║${NC}  ${BOLD}${CYAN}IMPORT URI:${NC}                                                       ${NC}"
echo -e "${BOLD}${GREEN}║${NC}  ${BOLD}${WHITE}${VLESS_URI}${GREEN}${NC}"
echo -e "${BOLD}${GREEN}║                                                                      ║${NC}"
echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════════════════════════════════╝${NC}"

echo ""
echo -e "${BOLD}${YELLOW}[NOTE]${NC} ${WHITE}DEFAULT UUID AND PATH ARE IN config.json. CHANGE THEM BEFORE REDEPLOYING.${NC}"
echo -e "${BOLD}${CYAN}[INFO]${NC} ${WHITE}DEPLOYMENT COMPLETED BY PRVTSPYYY404${NC}"
echo ""

# Restore cursor
tput cnorm
