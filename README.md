# VLESS on Google Cloud Run - Automated Deployer

**Deploy a private or public VLESS proxy over WebSocket on Google Cloud Run with a single command.**

This project automates the entire deployment lifecycle: enabling APIs, building a container with Xray-core and a health check server, pushing to Google Container Registry, and deploying to Cloud Run with configurable CPU, memory, and region. It is designed to work even within restricted environments (e.g., Qwiklabs) by automatically falling back to private deployment when organization policies block public access.

---

## Features

- **One-command deployment** – Paste a single line in Cloud Shell and let the script handle everything.
- **Real-time region detection** – Only shows regions that are currently online and accessible in your GCP project, with clear visual status indicators.
- **Customizable resources** – Choose from five CPU/memory presets to match your performance needs.
- **Automatic policy fallback** – If Domain Restricted Sharing blocks public access, the script redeploys privately and generates service account credentials automatically.
- **Custom service naming** – Name your Cloud Run service whatever you want.
- **Full TLS support** – Traffic is encrypted using Google-managed SSL certificates.
- **Timeout optimized** – Cloud Run request timeout set to 3600 seconds (1 hour) for long-lived WebSocket connections.

---

## Prerequisites

- A Google Cloud Platform account (free trial works perfectly).
- Billing enabled on your GCP project (Cloud Run free tier includes 2 million requests/month).
- Google Cloud Shell access – the script runs entirely within Cloud Shell.
- Basic familiarity with the GCP Console (only for monitoring logs if needed).

---

## Quick Start (One-Line Deployment)

1. Open [Google Cloud Shell](https://console.cloud.google.com/).
2. Ensure a project is selected (`gcloud config set project YOUR_PROJECT_ID`).
3. Run the following command:

```bash
git clone https://github.com/m4kethappy651/gcp && cd gcp && chmod +x deploy.sh && ./deploy.sh
```

1. Answer the interactive prompts:
   · Select a region (only online regions are displayed).
   · Choose CPU and memory allocation.
   · (Optional) Enter a custom service name.
2. Wait for the build and deployment to finish. At the end, an import-ready VLESS URI will be displayed.

---

Detailed Deployment Walkthrough

Step 1: Clone and Enter the Repository

```bash
git clone https://github.com/m4kethappy651/gcp
cd gcp
```

Step 2: (Optional) Customize UUID and WebSocket Path

Edit config.json to change the default credentials:

```json
{
  "inbounds": [
    {
      "port": 8080,
      "listen": "0.0.0.0",
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "YOUR-UUID-HERE",
            "level": 0
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/YOUR-SECRET-PATH"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom"
    }
  ]
}
```

Step 3: Run the Deployer

```bash
chmod +x deploy.sh
./deploy.sh
```

Step 4: Follow the Prompts

· Region selection – The script tests multiple regions in real time. Only regions that successfully respond are shown as selectable options.
· CPU and Memory – Choose from five presets ranging from 1 vCPU/1 GiB to 4 vCPU/4 GiB.
· Service name – Defaults to vless-ws. You may enter a custom name (lowercase letters, numbers, hyphens only).

Step 5: Save the Output

At the end of the deployment, the script prints a complete VLESS connection URI. Copy it into your client (v2rayNG, Nekobox, Shadowrocket, etc.).

Example output:

```
========================================
        VLESS CONNECTION DETAILS
========================================
Protocol: VLESS
Address:  vless-ws-xxxxxxxxx-uc.a.run.app
Port:     443
UUID:     a3b7de87-b46f-4dcf-b6ed-5bf5ebe83167
WS Path:  /notragnar
Transport: WebSocket (ws)
TLS:      Enabled (Google Managed)

Import URI:
vless://a3b7de87-b46f-4dcf-b6ed-5bf5ebe83167@vless-ws-xxxxxxxxx-uc.a.run.app:443?encryption=none&security=tls&type=ws&path=/notragnar#GCP-VLESS
========================================
```

---

Client Configuration (Manual)

If you prefer to enter settings manually, use the following template:

Field Value
Protocol VLESS
Address vless-ws-xxxxxxxxx-uc.a.run.app
Port 443
UUID / ID As defined in config.json
Encryption none
Transport ws (WebSocket)
Path As defined in config.json
TLS / Security tls (Enabled)

Retrieve your exact service URL with:

```bash
gcloud run services describe vless-ws --region YOUR_REGION --format='value(status.url)' | sed 's|https://||'
```

---

Troubleshooting

The container fails to start (PORT=8080 error)

Cause: Cloud Run requires a health check endpoint that returns HTTP 200. Xray does not speak HTTP.

Solution: This project includes a lightweight Python HTTP server that runs alongside Xray, answering health checks on port 8080. If you encounter this error, ensure you are using the latest Dockerfile from the repository.

Deployment hangs or times out during gcloud run deploy

Cause: The Qwiklabs environment may throttle API calls or have network latency.

Solution: The script now uses raw gcloud commands without artificial timeouts. Wait up to 5 minutes. If it still fails, try redeploying to a different region.

ERROR: (gcloud.run.deploy) FAILED_PRECONDITION: Setting IAM policy failed

Cause: Organization policy (Domain Restricted Sharing) prevents granting allUsers the run.invoker role.

Solution: The script automatically detects this failure and redeploys the service as private. It then creates a service account and provides authentication instructions. Look for the "CLIENT AUTHENTICATION REQUIRED" box in the output.

No regions are displayed as online

Cause: The Cloud Run API may not be fully enabled, or organization policy restricts all tested regions.

Solution: Manually verify API status:

```bash
gcloud services enable run.googleapis.com --quiet
```

If the problem persists, deploy using the fallback region us-central1 by answering "1" when prompted.

Quota exceeded error

Cause: Your project has reached the Cloud Run memory quota for the selected region.

Solution: Choose a different region when prompted. The free tier quotas are regional; deploying to us-east1 or europe-west1 often resolves this.

---

File Structure

```
gcp/
├── deploy.sh            # Main deployment script
├── Dockerfile           # Container definition (Xray + Python health server)
├── config.json          # Xray inbound configuration
└── README.md            # This file
```

---

Thank You & Appreciation

This project exists because of your patience, detailed feedback, and relentless testing. Every error message, every failed build, and every region timeout contributed to making this script robust and reliable.

Special thanks to:

· prvtspyyy404 – for the vision, the name, and the insistence on perfection.
· Everyone who tested this in Qwiklabs, personal GCP accounts, and beyond – your logs made the difference.

If this tool saves you time or helps you bypass restrictions, I've done my job. If you find a new edge case or a bug, open an issue – I'll be here.

---

License

MIT License – do whatever you want with this code. Modify it, share it, improve it. Attribution is appreciated but not required.

---

Deploy fast. Stay secure.

```
FB > https://www.facebook.com/saekacutiee
TG > t.me/prvtspy

> THANK YOU TO ALL THE VOLUNTEERS THAT HELPED ME TO MAKE THIS PROJECT POSSIBLE <
