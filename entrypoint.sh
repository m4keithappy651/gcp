#!/bin/sh
/usr/bin/xray run -c /etc/xray/config.json &
exec /usr/bin/caddy run --config /etc/caddy/Caddyfile
