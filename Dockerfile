FROM teddysun/xray:latest

# Install socat for instant health check
RUN apk update && apk add --no-cache socat && rm -rf /var/cache/apk/*

# Copy Xray configuration
COPY config.json /etc/xray/config.json

# Entrypoint: socat health server FIRST, then Xray
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'while true; do echo -e "HTTP/1.1 200 OK\r\n\r\nOK" | socat TCP-LISTEN:8080,fork,reuseaddr -; done &' >> /entrypoint.sh && \
    echo 'exec /usr/bin/xray run -c /etc/xray/config.json' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
