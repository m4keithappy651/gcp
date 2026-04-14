FROM caddy:2-alpine AS caddy
FROM teddysun/xray:latest

# Copy Caddy binary from the official image
COPY --from=caddy /usr/bin/caddy /usr/bin/caddy

# Copy Xray configuration (listening on internal port 8081)
COPY config.json /etc/xray/config.json

# Create Caddyfile to route traffic
RUN echo ':8080 {' > /etc/caddy/Caddyfile && \
    echo '    respond /health 200' >> /etc/caddy/Caddyfile && \
    echo '    handle_path /prvtspyyy {' >> /etc/caddy/Caddyfile && \
    echo '        reverse_proxy localhost:8081' >> /etc/caddy/Caddyfile && \
    echo '    }' >> /etc/caddy/Caddyfile && \
    echo '}' >> /etc/caddy/Caddyfile

# Entrypoint: Start Xray in background, Caddy in foreground
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo '/usr/bin/xray run -c /etc/xray/config.json &' >> /entrypoint.sh && \
    echo 'exec /usr/bin/caddy run --config /etc/caddy/Caddyfile' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
