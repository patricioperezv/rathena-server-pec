FROM debian:12

# Define the ARG for the revision to be cloned
ARG REVISION=master

# Define the ARG for the build configuration
ARG BUILD_CONFIGURE="--enable-packetver=20211103"

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
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Download and set permissions for wait-for script
RUN wget https://raw.githubusercontent.com/eficode/wait-for/v2.2.4/wait-for -O /bin/wait-for && \
    chmod +x /bin/wait-for

# Clone the rathena repository and fetch the specified commit
RUN git init /rathena && \
    cd /rathena && \
    git remote add origin https://github.com/rathena/rathena.git && \
    git fetch --depth 1 origin ${REVISION} && \
    git checkout FETCH_HEAD

# Set the build configuration as an environment variable
ENV BUILD_CONFIGURE=${BUILD_CONFIGURE}

# Set the working directory
WORKDIR /rathena

RUN ./configure ${BUILD_CONFIGURE} && \
    make clean && \
    make server
