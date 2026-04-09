FROM teddysun/xray:latest
RUN apt-get update && apt-get install -y gettext && rm -rf /var/lib/apt/lists/*
ENV UUID="" WS_PATH="/ws"
COPY config.template.json /etc/xray/config.template.json
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
