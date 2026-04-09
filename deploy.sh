#!/bin/bash
set -e

# ==============================================
# AUTOMATED VLESS DEPLOYMENT SCRIPT FOR GCP
# ==============================================

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   VLESS GCP AUTOMATED DEPLOYMENT       ${NC}"
echo -e "${GREEN}========================================${NC}"

# --- STEP 1: Project Configuration ---
PROJECT_ID=$(gcloud config get-value project)
if [ -z "$PROJECT_ID" ]; then
  echo -e "${YELLOW}No project set. Creating new project...${NC}"
  PROJECT_ID="vless-$(date +%s)"
  gcloud projects create $PROJECT_ID --name="VLESS Proxy"
  gcloud config set project $PROJECT_ID
fi

echo -e "${GREEN}[1/7] Project: $PROJECT_ID${NC}"

# Enable required APIs
echo -e "${GREEN}[2/7] Enabling required APIs...${NC}"
gcloud services enable run.googleapis.com containerregistry.googleapis.com

# --- STEP 2: Generate Security Parameters ---
UUID=$(cat /proc/sys/kernel/random/uuid)
WS_PATH="/$(openssl rand -hex 8)"
REGION="us-central1"

echo -e "${GREEN}[3/7] Generated security parameters${NC}"
echo "    UUID: $UUID"
echo "    WS Path: $WS_PATH"

# --- STEP 3: Build Docker Image ---
echo -e "${GREEN}[4/7] Building Docker image...${NC}"
IMAGE_NAME="gcr.io/$PROJECT_ID/vless-ws:latest"

docker build -t $IMAGE_NAME \
  --build-arg UUID=$UUID \
  --build-arg WS_PATH=$WS_PATH \
  .

# --- STEP 4: Push to Container Registry ---
echo -e "${GREEN}[5/7] Pushing to Google Container Registry...${NC}"
docker push $IMAGE_NAME

# --- STEP 5: Deploy to Cloud Run ---
echo -e "${GREEN}[6/7] Deploying to Cloud Run...${NC}"
gcloud run deploy vless-ws \
  --image $IMAGE_NAME \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --port 8080 \
  --set-env-vars "UUID=$UUID,WS_PATH=$WS_PATH"

# Get the service URL
SERVICE_URL=$(gcloud run services describe vless-ws --region $REGION --format='value(status.url)')

echo -e "${GREEN}[7/7] Deployment complete!${NC}"

# --- STEP 6: Output Connection Details ---
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}        VLESS CONNECTION DETAILS        ${NC}"
echo -e "${GREEN}========================================${NC}"

# Generate import-ready VLESS URI
VLESS_URI="vless://$UUID@$SERVICE_URL:443?encryption=none&security=tls&type=ws&path=$WS_PATH#GCP-VLESS"

echo -e "${YELLOW}Protocol:${NC} VLESS"
echo -e "${YELLOW}Address:${NC} $(echo $SERVICE_URL | sed 's|https://||')"
echo -e "${YELLOW}Port:${NC} 443"
echo -e "${YELLOW}UUID:${NC} $UUID"
echo -e "${YELLOW}Encryption:${NC} none"
echo -e "${YELLOW}Transport:${NC} WebSocket (ws)"
echo -e "${YELLOW}Path:${NC} $WS_PATH"
echo -e "${YELLOW}TLS:${NC} Yes (Google-managed)"
echo -e ""
echo -e "${GREEN}Import-ready URI:${NC}"
echo -e "$VLESS_URI"
echo -e ""
echo -e "${GREEN}========================================${NC}"

# --- BONUS: Setup Load Balancer + CDN (One-time setup) ---
create_cdn_frontend() {
  echo -e "${GREEN}Setting up Global Load Balancer with CDN...${NC}"
  
  # Reserve a global static IP
  gcloud compute addresses create vless-ip --global
  
  # Get the IP address
  STATIC_IP=$(gcloud compute addresses describe vless-ip --global --format='value(address)')
  
  # Create backend service pointing to Cloud Run
  gcloud compute backend-services create vless-backend \
    --global \
    --enable-cdn \
    --protocol=HTTPS
  
  # Add Cloud Run NEG (Network Endpoint Group)
  gcloud beta compute network-endpoint-groups create vless-neg \
    --region=$REGION \
    --network-endpoint-type=serverless \
    --cloud-run-service=vless-ws
  
  # Attach NEG to backend
  gcloud compute backend-services add-backend vless-backend \
    --global \
    --network-endpoint-group=vless-neg \
    --network-endpoint-group-region=$REGION
  
  # Create URL map and target proxy
  gcloud compute url-maps create vless-url-map \
    --default-service vless-backend
  
  gcloud compute target-https-proxies create vless-https-proxy \
    --url-map=vless-url-map \
    --ssl-certificates=YOUR_CERTIFICATE
  
  # Create forwarding rule
  gcloud compute forwarding-rules create vless-forwarding-rule \
    --global \
    --target-https-proxy=vless-https-proxy \
    --address=$STATIC_IP \
    --ports=443
  
  echo -e "${GREEN}CDN setup complete. Static IP: $STATIC_IP${NC}"
}
