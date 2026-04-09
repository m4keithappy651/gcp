FROM teddysun/xray:latest

# Install envsubst for configuration templating
RUN apt-get update && apt-get install -y gettext && rm -rf /var/lib/apt/lists/*

# Environment variables for dynamic config
ENV UUID=""
ENV WS_PATH="/ws"

# Copy configuration template and entrypoint script
COPY config.template.json /etc/xray/config.template.json
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

# Cloud Run requires listening on 8080
EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
