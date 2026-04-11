FROM teddysun/xray:latest

# Install only essential packages and clean up in the same layer
RUN apk update && apk add --no-cache busybox-extras && \
    rm -rf /var/cache/apk/*

# Copy configuration
COPY config.json /etc/xray/config.json

# Create entrypoint script with combined commands
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'busybox httpd -f -p 8080 -h /tmp &' >> /entrypoint.sh && \
    echo '/usr/bin/xray run -c /etc/xray/config.json' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
