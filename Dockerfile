FROM teddysun/xray:latest

# No additional packages needed - nc is already present
COPY config.json /etc/xray/config.json

# Entrypoint: Start shell health server on 8081 FIRST, then Xray on 8080
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo '# Start instant health check server on port 8081' >> /entrypoint.sh && \
    echo 'while true; do printf "HTTP/1.1 200 OK\r\n\r\nOK" | nc -l -p 8081 -q 1; done &' >> /entrypoint.sh && \
    echo '# Give health server time to bind' >> /entrypoint.sh && \
    echo 'sleep 0.5' >> /entrypoint.sh && \
    echo '# Start Xray on port 8080' >> /entrypoint.sh && \
    echo 'exec /usr/bin/xray run -c /etc/xray/config.json' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

EXPOSE 8080 8081
ENTRYPOINT ["/entrypoint.sh"]
