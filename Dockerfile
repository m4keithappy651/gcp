FROM caddy:2-alpine AS caddy
FROM teddysun/xray:latest
COPY --from=caddy /usr/bin/caddy /usr/bin/caddy
RUN printf ':8080 {\n    respond /health 200\n    handle_path /notragnar {\n        reverse_proxy localhost:8081\n    }\n}\n' > /etc/caddy/Caddyfile
COPY config.json /etc/xray/config.json
RUN printf '#!/bin/sh\n/usr/bin/xray run -c /etc/xray/config.json &\n/usr/bin/caddy run --config /etc/caddy/Caddyfile\n' > /entrypoint.sh && chmod +x /entrypoint.sh
EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
