FROM teddysun/xray:latest

# Install only the essential lightweight web server for health checks
RUN apk update && apk add --no-cache busybox-extras && \
    rm -rf /var/cache/apk/*

# Copy your optimized Xray configuration
COPY config.json /etc/xray/config.json

# Create a robust entrypoint script that properly backgrounds the health server
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo '# Start a simple HTTP server for Cloud Run health checks on port 8080' >> /entrypoint.sh && \
    echo 'busybox httpd -f -p 8080 -h /tmp &' >> /entrypoint.sh && \
    echo '# Start Xray as the main foreground process' >> /entrypoint.sh && \
    echo 'exec /usr/bin/xray run -c /etc/xray/config.json' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
