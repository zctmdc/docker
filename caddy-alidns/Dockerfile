FROM caddy:builder AS builder

RUN go env -w GOPROXY=https://goproxy.io,direct \
  && git config --global url."https://gitclone.com/".insteadOf https:// \
  && xcaddy build \
    # --with github.com/caddyserver/nginx-adapter \
    --with github.com/caddy-dns/alidns

FROM caddy

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
