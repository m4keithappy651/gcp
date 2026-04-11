FROM teddysun/xray:latest

# Install busybox-extras for the lightweight httpd server
RUN apk update && apk add --no-cache busybox-extras && rm -rf /var/cache/apk/*

# Copy the Xray configuration
COPY config.json /etc/xray/config.json

# Create entrypoint script that runs the health check server AND Xray
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo '# Start a simple HTTP server for Cloud Run health checks on port 8080' >> /entrypoint.sh && \
    echo 'busybox httpd -f -p 8080 -h /tmp &' >> /entrypoint.sh && \
    echo '# Start Xray' >> /entrypoint.sh && \
    echo '/usr/bin/xray run -c /etc/xray/config.json' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
