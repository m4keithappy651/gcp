FROM teddysun/xray:latest

# Install socat for instant health check
RUN apk update && apk add --no-cache socat && \
    rm -rf /var/cache/apk/*

# Copy Xray configuration
COPY config.json /etc/xray/config.json

# Entrypoint: instant health check + Xray
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo '# Start instant health check responder on port 8080' >> /entrypoint.sh && \
    echo 'while true; do echo -e "HTTP/1.1 200 OK\r\n\r\nPrvtspy404" | socat TCP-LISTEN:8080,fork,reuseaddr -; done &' >> /entrypoint.sh && \
    echo '# Start Xray' >> /entrypoint.sh && \
    echo 'exec /usr/bin/xray run -c /etc/xray/config.json' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
