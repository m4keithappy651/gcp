# Stage 1: Build the supervisor (health server + Xray launcher)
FROM golang:1.21-alpine AS builder
WORKDIR /app

# Create the supervisor Go program
RUN echo 'package main; import ("net/http"; "os/exec"; "log"); func main() { go func() { http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) { w.WriteHeader(200) }); log.Fatal(http.ListenAndServe(":8080", nil)) }(); cmd := exec.Command("/app/xray", "run", "-c", "/app/config.json"); cmd.Stdout = log.Writer(); cmd.Stderr = log.Writer(); log.Fatal(cmd.Run()) }' > main.go

# Build the static binary
RUN CGO_ENABLED=0 GOOS=linux go build -o supervisor main.go

# Stage 2: Download and prepare Xray
FROM alpine:latest AS xray-prep
RUN apk add --no-cache wget unzip && \
    wget -q https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip Xray-linux-64.zip && \
    chmod +x xray

# Stage 3: Final minimal image
FROM gcr.io/distroless/static-debian12:nonroot
WORKDIR /app

# Copy the supervisor binary from Stage 1
COPY --from=builder /app/supervisor /app/supervisor

# Copy Xray binary and assets from Stage 2
COPY --from=xray-prep /xray /app/xray
COPY --from=xray-prep /geoip.dat /app/geoip.dat
COPY --from=xray-prep /geosite.dat /app/geosite.dat

# Copy your Xray configuration
COPY config.json /app/config.json

USER nonroot:nonroot

EXPOSE 8080
ENTRYPOINT ["/app/supervisor"]
