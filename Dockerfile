FROM teddysun/xray:latest

# No additional packages needed - use built-in shell
COPY config.json /etc/xray/config.json

# Entrypoint: Start a simple HTTP server FIRST, then Xray
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo '# Start instant health check server using only shell' >> /entrypoint.sh && \
    echo 'while true; do printf "HTTP/1.1 200 OK\r\n\r\nPrvtspy404" | nc -l -p 8080 -q 1; done &' >> /entrypoint.sh && \
    echo '# Give health server a moment to bind' >> /entrypoint.sh && \
    echo 'sleep 0.5' >> /entrypoint.sh && \
    echo '# Start Xray' >> /entrypoint.sh && \
    echo 'exec /usr/bin/xray run -c /etc/xray/config.json' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
