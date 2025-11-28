# Universal CUDA 12.8 builder image for AI/ML project builds on QuickPod
FROM nvidia/cuda:12.8-devel-ubuntu22.04

# Set working directory
WORKDIR /workspace

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install system dependencies and build tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Docker CLI and tools
    docker.io \
    docker-buildx \
    docker-compose-plugin \
    # Build toolchain
    gcc \
    g++ \
    make \
    cmake \
    ninja-build \
    pkg-config \
    # Python 3.12
    python3.12 \
    python3.12-dev \
    python3.12-venv \
    python3-pip \
    build-essential \
    # Git and GitHub CLI
    git \
    git-lfs \
    gh \
    # FFmpeg with CUDA support
    ffmpeg \
    # Audio libraries
    sox \
    libsndfile1-dev \
    libportaudio2 \
    libasound2-dev \
    libpulse-dev \
    # Image libraries
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    # Network/SSL libraries
    libssl-dev \
    libcurl4-openssl-dev \
    # Compression libraries
    zlib1g-dev \
    liblzma-dev \
    # Math libraries
    libopenblas-dev \
    liblapack-dev \
    # Utilities
    curl \
    wget \
    unzip \
    jq \
    vim \
    nano \
    htop \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Upgrade CMake to version 3.25 or higher
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null \
    && echo "deb https://apt.kitware.com/ubuntu/ jammy main" | tee /etc/apt/sources.list.d/kitware.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends cmake \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Set up Python 3.12 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1

# Install latest pip
RUN python3 -m pip install --upgrade pip

# Set up buildx with registry cache support
RUN docker buildx create --name builder --driver docker-container --use \
    && docker buildx inspect --bootstrap

# Create symbolic links for Docker CLI compatibility
RUN ln -sf /usr/libexec/docker/cli-plugins/docker-buildx /usr/bin/docker-buildx \
    && ln -sf /usr/libexec/docker/cli-plugins/docker-compose /usr/bin/docker-compose

# Verify installations
RUN cmake --version \
    && python3 --version \
    && pip --version \
    && docker --version \
    && docker buildx version \
    && docker compose version \
    && git --version \
    && gh --version \
    && ffmpeg -version | head -n1

# Set default command
CMD ["/bin/bash"]
