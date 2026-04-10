FROM caddy:2-alpine AS caddy
FROM teddysun/xray:latest
COPY --from=caddy /usr/bin/caddy /usr/bin/caddy
RUN echo ':8080 {' > /etc/caddy/Caddyfile
RUN echo '    respond /health 200' >> /etc/caddy/Caddyfile
RUN echo '    handle_path /notragnar {' >> /etc/caddy/Caddyfile
RUN echo '        reverse_proxy localhost:8081' >> /etc/caddy/Caddyfile
RUN echo '    }' >> /etc/caddy/Caddyfile
RUN echo '}' >> /etc/caddy/Caddyfile
COPY config.json /etc/xray/config.json
RUN echo '#!/bin/sh' > /entrypoint.sh
RUN echo '/usr/bin/xray run -c /etc/xray/config.json &' >> /entrypoint.sh
RUN echo '/usr/bin/caddy run --config /etc/caddy/Caddyfile' >> /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
