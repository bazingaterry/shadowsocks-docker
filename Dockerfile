FROM ubuntu:latest

ENV BUILD_DEPS git-core gettext build-essential autoconf asciidoc xmlto zlib1g-dev automake ca-certificates
ENV RUNTIME_DEPS libev-dev libc-ares-dev libsodium-dev libmbedtls-dev libtool libssl-dev libpcre3-dev
ENV SSDIR /tmp/shadowsocks-libev
ENV OBFSDIR /tmp/simple-obfs

ENV PORT 8839
ENV LISTEN "-s 0.0.0.0"
ENV TIMEOUT 600

# Set up building environment
RUN apt-get update && apt-get install --no-install-recommends -y $BUILD_DEPS $RUNTIME_DEPS

# Get the latest shadowsocks-libev code, build and install
RUN git clone https://github.com/shadowsocks/shadowsocks-libev.git $SSDIR
WORKDIR $SSDIR
RUN git submodule update --init --recursive \
 && ./autogen.sh \
 && ./configure \
 && make \
 && make install

# Get the latest simple-obfs code, build and install
RUN git clone https://github.com/shadowsocks/simple-obfs.git $OBFSDIR
WORKDIR $OBFSDIR
RUN git submodule update --init --recursive \
 && ./autogen.sh \
 && ./configure \
 && make \
 && make install

# Tear down building environment and delete git repository
WORKDIR /
RUN rm -rf $SSDIR && rm -rf $OBFSDIR && apt-get --purge autoremove -y $DEPENDENCIES

EXPOSE $PORT
CMD ss-manager --manager-address 0.0.0.0:$PORT $LISTEN -t $TIMEOUT
