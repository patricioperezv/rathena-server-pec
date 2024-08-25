FROM debian:12

# Define the ARG for the revision to be cloned
ARG REVISION=master

# Define the ARG for the build configuration
ARG BUILD_CONFIGURE="--enable-packetver=20211103"

ENV WAIT_FOR_VERSION=2.2.4
ENV GOMPLATE_VERSION=4.1.0


# Install necessary dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        make \
        libmariadb-dev \
        libmariadbclient-dev-compat \
        gcc \
        g++ \
        zlib1g-dev \
        libpcre3-dev \
        wget \
        ca-certificates \
        netcat-traditional && \
    rm -rf /var/lib/apt/lists/*

# Download and set permissions for wait-for script
RUN wget https://raw.githubusercontent.com/eficode/wait-for/v${WAIT_FOR_VERSION}/wait-for -O /bin/wait-for && \
    chmod +x /bin/wait-for

# Download and install gomplate
RUN wget https://github.com/hairyhenderson/gomplate/releases/download/v${GOMPLATE_VERSION}/gomplate_linux-amd64 -O /bin/gomplate && \
    chmod +x /bin/gomplate

# Create a non-root user and group
RUN groupadd -r rathena && useradd -r -g rathena rathena

# Set the working directory and change ownership to the non-root user
WORKDIR /rathena
RUN chown -R rathena:rathena /rathena

# Switch to the non-root user
USER rathena

# Clone the rathena repository and fetch the specified commit
RUN git init /rathena && \
    cd /rathena && \
    git remote add origin https://github.com/rathena/rathena.git && \
    git fetch --depth 1 origin ${REVISION} && \
    git checkout FETCH_HEAD

# Set the build configuration as an environment variable
ENV BUILD_CONFIGURE=${BUILD_CONFIGURE}

# Run the build commands
RUN ./configure ${BUILD_CONFIGURE} && \
    make clean && \
    make server

# Default command
CMD ["bash"]
