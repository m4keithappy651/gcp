FROM teddysun/xray:latest

# Copy the configuration file
COPY config.json /etc/xray/config.json

# Expose the required port
EXPOSE 8080

# Start Xray directly
CMD ["/usr/bin/xray", "run", "-c", "/etc/xray/config.json"]
