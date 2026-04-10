FROM teddysun/xray:latest

# Install Python for health check server (Alpine uses apk)
RUN apk update && apk add --no-cache python3 && rm -rf /var/cache/apk/*

# Copy configuration
COPY config.json /etc/xray/config.json

# Create entrypoint script that runs health check server and Xray
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'python3 -m http.server 8080 --bind 0.0.0.0 &' >> /entrypoint.sh && \
    echo '/usr/bin/xray run -c /etc/xray/config.json' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
