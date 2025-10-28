###########################
# Builder image
###########################
FROM debian:trixie-20251020 AS builder

ARG MONERO_V=0.18.4.3
ENV MONERO_V=${MONERO_V}

# Install all build dependencies
RUN apt-get update && apt-get install -y \
    build-essential cmake pkg-config git python3 python3-pip \
    python3-setuptools python3-dev \
    libzmq3-dev libssl-dev libunbound-dev libsodium-dev libunwind8-dev \
    liblzma-dev libreadline-dev libldns-dev libexpat1-dev libpgm-dev \
    qttools5-dev-tools libhidapi-dev libusb-1.0-0-dev libprotobuf-dev \
    protobuf-compiler libudev-dev \
    libboost-chrono-dev libboost-date-time-dev libboost-filesystem-dev \
    libboost-locale-dev libboost-program-options-dev libboost-regex-dev \
    libboost-serialization-dev libboost-system-dev libboost-thread-dev \
    ccache doxygen graphviz libgtest-dev

# Build Google Test
WORKDIR /usr/src/gtest
RUN cmake . && make -j4 && mv lib/*.a /usr/lib/

# Clone and build Monero
WORKDIR /opt
RUN git clone -b v${MONERO_V} --recursive --depth=1 https://github.com/monero-project/monero
WORKDIR /opt/monero
RUN make -j$(nproc)

###########################
# Production image
###########################
FROM debian:trixie-20251020

ARG MONERO_V=0.18.4.3
ENV MONERO_V=${MONERO_V}

# Install runtime dependencies only
RUN apt-get update && apt-get install -y \
    libboost-chrono-dev libboost-date-time-dev libboost-filesystem-dev \
    libboost-program-options-dev libboost-regex-dev libboost-thread-dev \
    libzmq3-dev libreadline-dev libhidapi-dev libusb-1.0-0-dev \
    libunbound-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy Monero binaries
COPY --from=builder /opt/monero/build/Linux/_no_branch_/release/bin/* /usr/local/bin/

# Setup runtime directories
RUN mkdir -p /data /log

# Add configuration
COPY monerod.conf /monerod.conf

# Default command
CMD [ "monerod", "--config-file", "/monerod.conf", "--non-interactive" ]
