FROM golang:1.21-alpine AS builder
WORKDIR /app
RUN echo 'package main\n\nimport (\n\t"net/http"\n\t"net/http/httputil"\n\t"net/url"\n\t"strings"\n)\n\nfunc main() {\n\ttarget, _ := url.Parse("http://127.0.0.1:8081")\n\tproxy := httputil.NewSingleHostReverseProxy(target)\n\thttp.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {\n\t\tif strings.HasPrefix(r.URL.Path, "/prvtspyyy") {\n\t\t\tproxy.ServeHTTP(w, r)\n\t\t} else {\n\t\t\tw.WriteHeader(200)\n\t\t\tw.Write([]byte("Prvtspy404"))\n\t\t}\n\t})\n\thttp.ListenAndServe(":8080", nil)\n}' > proxy.go
RUN CGO_ENABLED=0 GOOS=linux go build -o proxy proxy.go

FROM teddysun/xray:latest
RUN apk update && apk add --no-cache dropbear && rm -rf /var/cache/apk/*
RUN mkdir -p /etc/dropbear && dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key && echo "root:prvtspyyy404" | chpasswd
COPY --from=builder /app/proxy /usr/bin/proxy
COPY config.json /etc/xray/config.json
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo '/usr/bin/proxy &' >> /entrypoint.sh && \
    echo 'dropbear -p 2222 -E &' >> /entrypoint.sh && \
    echo 'exec /usr/bin/xray run -c /etc/xray/config.json' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh
EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
