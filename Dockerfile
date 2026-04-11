FROM teddysun/xray:latest

# Install essential packages and clean up in a single layer
RUN apk update && apk add --no-cache bash busybox-extras && \
    rm -rf /var/cache/apk/*

# Increase system file descriptor limit for high concurrency
RUN ulimit -n 65535

# Copy configuration
COPY config.json /etc/xray/config.json

# Create entrypoint script that isolates the health check and Xray
RUN echo '#!/bin/bash' > /entrypoint.sh && \
    echo '# Start a simple HTTP server for Cloud Run health checks on port 8080' >> /entrypoint.sh && \
    echo 'busybox httpd -f -p 8080 -h /tmp &' >> /entrypoint.sh && \
    echo '# Start Xray with increased file descriptor limit' >> /entrypoint.sh && \
    echo 'ulimit -n 65535' >> /entrypoint.sh && \
    echo '/usr/bin/xray run -c /etc/xray/config.json' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
