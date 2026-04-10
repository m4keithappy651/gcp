FROM teddysun/xray:latest

# Python is already present in the base image. No additional packages needed.
# Create a simple Python health check server script
RUN echo '#!/usr/bin/env python3\n\
import http.server\n\
import socketserver\n\
import sys\n\
\n\
class HealthHandler(http.server.SimpleHTTPRequestHandler):\n\
    def do_GET(self):\n\
        self.send_response(200)\n\
        self.send_header("Content-type", "text/plain")\n\
        self.end_headers()\n\
        self.wfile.write(b"OK")\n\
\n\
if __name__ == "__main__":\n\
    with socketserver.TCPServer(("0.0.0.0", 8080), HealthHandler) as httpd:\n\
        httpd.serve_forever()\n\
' > /health.py && chmod +x /health.py

COPY config.json /etc/xray/config.json

# Entrypoint starts both the health server and Xray
RUN echo '#!/bin/sh\n\
python3 /health.py &\n\
/usr/bin/xray run -c /etc/xray/config.json' > /entrypoint.sh \
    && chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
