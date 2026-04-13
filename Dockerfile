# Stage 1: Build embedded SSH server in Go
FROM golang:1.21-alpine AS builder
WORKDIR /app
RUN go mod init ssh-vless && \
    go get github.com/gliderlabs/ssh
RUN echo 'package main; import ( "io"; "log"; "net"; "os"; "os/exec"; "github.com/gliderlabs/ssh" ); func main() { ssh.Handle(func(s ssh.Session) { cmd := exec.Command("/bin/sh"); stdin, _ := cmd.StdinPipe(); stdout, _ := cmd.StdoutPipe(); stderr, _ := cmd.StderrPipe(); go func() { io.Copy(stdin, s) }(); go func() { io.Copy(s, stdout) }(); go func() { io.Copy(s.Stderr(), stderr) }(); cmd.Run() }); log.Fatal(ssh.ListenAndServe(":2222", nil, ssh.PasswordAuth(func(ctx ssh.Context, pass string) bool { return ctx.User() == "root" && pass == "prvtspyyy404" }))) }' > sshd.go
RUN CGO_ENABLED=0 GOOS=linux go build -o sshd sshd.go

# Stage 2: Final image
FROM teddysun/xray:latest
COPY --from=builder /app/sshd /usr/bin/sshd
COPY config.json /etc/xray/config.json
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo '/usr/bin/sshd &' >> /entrypoint.sh && \
    echo 'exec /usr/bin/xray run -c /etc/xray/config.json' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh
EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
