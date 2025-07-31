###########################
# Builder image
###########################
FROM debian:trixie-20250721 AS builder
ENV MONERO_V=0.18.4.0


RUN apt-get update && apt-get install -y build-essential cmake pkg-config \
    libzmq3-dev libssl-dev libunbound-dev libsodium-dev libunwind8-dev \
    liblzma-dev libreadline-dev libldns-dev libexpat1-dev libpgm-dev \
    qttools5-dev-tools libhidapi-dev libusb-1.0-0-dev libprotobuf-dev \
    protobuf-compiler libudev-dev libboost-chrono-dev libboost-date-time-dev \
    libboost-filesystem-dev libboost-locale-dev libboost-program-options-dev \
    libboost-regex-dev libboost-serialization-dev libboost-system-dev \
    libboost-thread-dev ccache doxygen graphviz

RUN apt-get install libgtest-dev -y && \
    cd /usr/src/gtest && \
    cmake . && \
    make -j4 && \
    mv lib/*.a /usr/lib/

#    git config --global http.postBuffer 1048576000 && \
RUN apt-get update && \
    apt-get install -y \
        git \
        python3 \
        python3-pip \
        python3-setuptools \
        python3-dev && \
    git clone -b v${MONERO_V} --recursive --depth=1 https://github.com/monero-project/monero && \
    cd monero && git submodule init && git submodule update && \
    make -j2

###########################
# Production image
###########################
FROM debian:trixie-20250721
ENV MONERO_V=0.18.4.0

COPY --from=builder /monero/build/Linux/_no_branch_/release/bin/* /

RUN apt-get update && apt-get install -y \
    libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev \ 
    libboost-regex-dev libzmq3-dev libreadline-dev libhidapi-dev libusb-1.0-0-dev \
    libunbound-dev libboost-date-time-dev libboost-thread-dev

RUN mkdir /data && \
    mkdir /log 

COPY monerod.conf /monerod.conf

CMD [ "/monerod", "--config-file", "/monerod.conf", "--non-interactive" ]
