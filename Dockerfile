FROM caddy:2-alpine AS caddy
FROM teddysun/xray:latest

# Copy Caddy binary from the official image
COPY --from=caddy /usr/bin/caddy /usr/bin/caddy

# Copy Xray configuration
COPY config.json /etc/xray/config.json

# Create Caddyfile to route traffic
RUN echo ':8080 {' > /etc/caddy/Caddyfile && \
    echo '    respond /health 200' >> /etc/caddy/Caddyfile && \
    echo '    handle_path /prvtspyyy {' >> /etc/caddy/Caddyfile && \
    echo '        reverse_proxy localhost:8081' >> /etc/caddy/Caddyfile && \
    echo '    }' >> /etc/caddy/Caddyfile && \
    echo '}' >> /etc/caddy/Caddyfile

# Create a robust entrypoint script
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'set -e' >> /entrypoint.sh && \
    echo '# Start Xray in the background' >> /entrypoint.sh && \
    echo '/usr/bin/xray run -c /etc/xray/config.json &' >> /entrypoint.sh && \
    echo 'XRAY_PID=$!' >> /entrypoint.sh && \
    echo '# Give Xray a moment to start' >> /entrypoint.sh && \
    echo 'sleep 2' >> /entrypoint.sh && \
    echo '# Check if Xray is still running' >> /entrypoint.sh && \
    echo 'if ! kill -0 $XRAY_PID 2>/dev/null; then' >> /entrypoint.sh && \
    echo '    echo "ERROR: Xray failed to start!" >&2' >> /entrypoint.sh && \
    echo '    exit 1' >> /entrypoint.sh && \
    echo 'fi' >> /entrypoint.sh && \
    echo '# Start Caddy as the main process' >> /entrypoint.sh && \
    echo 'exec /usr/bin/caddy run --config /etc/caddy/Caddyfile' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
