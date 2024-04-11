FROM rust:1.77.2-alpine AS rust_builder

RUN <<EOT
  apk --no-cache --no-progress update
  apk --no-cache --no-progress add musl-dev openssl-dev sqlite-dev git
EOT

ENV RUSTFLAGS="-Ctarget-feature=-crt-static"

WORKDIR /usr/src/arti

ARG ARTI_VERSION=main
RUN git clone -b $ARTI_VERSION --single-branch --depth 1 https://gitlab.torproject.org/tpo/core/arti.git .

RUN cargo build -p arti --release

FROM golang:1.22.2-alpine AS go_builder

RUN <<EOT
  apk --no-cache --no-progress update
  apk --no-cache --no-progress add git
EOT

# Install obfs4proxy, snowflake and webtunnel
ARG OBFS4_VERSION=latest
ARG SNOWFLAKE_VERSION=latest
ARG WEBTUNNEL_VERSION=latest

RUN go install gitlab.com/yawning/obfs4.git/obfs4proxy@$OBFS4_VERSION

RUN <<EOT
  go install gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/snowflake/v2/client@$SNOWFLAKE_VERSION
  mv /go/bin/client /go/bin/snowflake-client
EOT

RUN <<EOT
  go install gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/webtunnel/main/client@$WEBTUNNEL_VERSION
  mv /go/bin/client /go/bin/webtunnel-client
EOT

FROM alpine:3.19.1

COPY --from=go_builder /go/bin/obfs4proxy /usr/bin/obfs4proxy
COPY --from=go_builder /go/bin/snowflake-client /usr/bin/snowflake-client
COPY --from=go_builder /go/bin/webtunnel-client /usr/bin/webtunnel-client
COPY --from=rust_builder /usr/src/arti/target/release/arti /usr/bin/arti

RUN <<EOT
  apk --no-cache --no-progress update
  apk --no-cache --no-progress add curl sqlite-libs libgcc
EOT

COPY arti.proxy.toml /home/arti/.config/arti/arti.d/

RUN adduser \
  --disabled-password \
  --home "/home/arti/" \
  --gecos "" \
  --shell "/sbin/nologin" \
  arti
USER arti

HEALTHCHECK --interval=5m --timeout=15s --start-period=20s \
  CMD curl -s --socks5-hostname localhost:9150 'https://check.torproject.org/' | \
  grep -qm1 Congratulations

# Cache information and persistent state
RUN mkdir -p /home/arti/.cache/arti/ /home/arti/.local/share/arti/
VOLUME [ "/home/arti/.cache/arti/" "/home/arti/.local/share/arti/" ]

EXPOSE 9150

ENTRYPOINT [ "arti" ]
CMD [ "proxy" ]
