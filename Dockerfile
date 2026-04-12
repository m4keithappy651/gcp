FROM teddysun/xray:latest

# Copy the Xray configuration
COPY config.json /etc/xray/config.json

EXPOSE 8080
ENTRYPOINT ["/usr/bin/xray", "run", "-c", "/etc/xray/config.json"]
