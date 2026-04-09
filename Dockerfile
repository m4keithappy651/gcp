FROM teddysun/xray:latest

# Set environment variables for dynamic configuration
ENV UUID=""
ENV WS_PATH="/ws"

# Copy configuration template and entrypoint script
COPY config.template.json /etc/xray/config.template.json
COPY entrypoint.sh /entrypoint.sh

# Expose the port Cloud Run will listen on
EXPOSE 8080

# Make entrypoint executable and set it
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
