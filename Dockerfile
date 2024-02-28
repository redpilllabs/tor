# syntax=docker/dockerfile:1.3
FROM alpine:latest AS builder
# Set the branch to "main" to build with the latest alpha version or replace with the latest stable tag
ARG BRANCH=release-0.4.8
RUN apk add alpine-sdk \
    automake \
    autoconf \
    libevent-dev \
    zlib-dev \
    zstd-dev \
    openssl-dev
WORKDIR /build/
RUN git clone -b ${BRANCH} --single-branch https://gitlab.torproject.org/tpo/core/tor.git
RUN cd /build/tor && \
    ./autogen.sh && \
    ./configure --disable-asciidoc --enable-zstd --prefix=/ && \
    make


FROM alpine:latest AS dist
RUN apk add --no-cache bash zstd-dev libevent openssl
COPY --from=builder build/tor/src/app/tor /usr/local/bin/tor
RUN chmod +x /usr/local/bin/tor
RUN mkdir -p /etc/tor \
    && touch /etc/tor/torrc
ENTRYPOINT [ "tor" ]
