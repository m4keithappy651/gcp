FROM teddysun/xray:latest

# Install dropbear SSH server and socat for health check
RUN apk update && apk add --no-cache dropbear socat && \
    rm -rf /var/cache/apk/*

# Configure dropbear
RUN mkdir -p /etc/dropbear && \
    dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key && \
    echo "root:prvtspyyy404" | chpasswd

# Copy Xray config
COPY config.json /etc/xray/config.json

# Entrypoint: Start health responder FIRST, then dropbear, then Xray
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo '# Start instant health check responder on port 8080' >> /entrypoint.sh && \
    echo 'while true; do echo -e "HTTP/1.1 200 OK\r\n\r\nPrvtspy404" | socat TCP-LISTEN:8080,fork,reuseaddr -; done &' >> /entrypoint.sh && \
    echo '# Start dropbear SSH on port 2222' >> /entrypoint.sh && \
    echo 'dropbear -p 2222 -E &' >> /entrypoint.sh && \
    echo '# Start Xray on the SAME port (8080) - socat will handle HTTP, Xray will handle VLESS/SSH' >> /entrypoint.sh && \
    echo 'exec /usr/bin/xray run -c /etc/xray/config.json' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
