FROM caddy:2-alpine AS caddy
FROM teddysun/xray:latest

COPY --from=caddy /usr/bin/caddy /usr/bin/caddy

# Create Caddyfile using heredoc (no escaping issues)
RUN cat > /etc/caddy/Caddyfile <<'EOF'
:8080 {
    respond /health 200
    handle_path /notragnar {
        reverse_proxy localhost:8081
    }
}
EOF

# Copy Xray configuration
COPY config.json /etc/xray/config.json

# Create entrypoint script using heredoc
RUN cat > /entrypoint.sh <<'EOF'
#!/bin/sh
/usr/bin/xray run -c /etc/xray/config.json &
/usr/bin/caddy run --config /etc/caddy/Caddyfile
EOF

RUN chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
