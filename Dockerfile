FROM teddysun/xray:latest

# Copy the configuration
COPY config.json /etc/xray/config.json

# Start Xray directly
EXPOSE 8080
ENTRYPOINT ["/usr/bin/xray", "run", "-c", "/etc/xray/config.json"]
