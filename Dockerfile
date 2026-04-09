FROM teddysun/xray:latest

# Install busybox for a lightweight, reliable HTTP server
RUN apk update && apk add --no-cache busybox-extras && rm -rf /var/cache/apk/*

# Copy configuration
COPY config.json /etc/xray/config.json

# Create a robust entrypoint script
RUN echo '#!/bin/sh\n\
# Start a simple HTTP server for Cloud Run health checks on port 8080\n\
busybox httpd -f -p 8080 -h /tmp &\n\
# Start Xray\n\
/usr/bin/xray run -c /etc/xray/config.json' > /entrypoint.sh \
    && chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
