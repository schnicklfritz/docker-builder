# Universal CUDA 12.8 builder image for AI/ML project builds on QuickPod
FROM nvidia/cuda:12.8.0-devel-ubuntu24.04

# Set working directory
WORKDIR /workspace

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install system dependencies and build tools (minimal set for AI/ML builds)
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Docker CLI and tools
    docker.io \
    docker-buildx \
    # Build toolchain
    gcc \
    g++ \
    make \
    cmake \
    ninja-build \
    pkg-config \
    # Python 3.12 (available in Ubuntu 24.04)
    python3 \
    python3-dev \
    python3-venv \
    python3-pip \
    build-essential \
    # Git and tools
    git \
    git-lfs \
    # FFmpeg with CUDA support
    ffmpeg \
    # Audio libraries
    sox \
    libsndfile1-dev \
    # Image libraries
    libjpeg-dev \
    libpng-dev \
    # Network/SSL libraries
    libssl-dev \
    libcurl4-openssl-dev \
    # Compression libraries
    zlib1g-dev \
    # Math libraries
    libopenblas-dev \
    # Utilities
    curl \
    wget \
    unzip \
    jq \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Verify CMake version (CUDA base image should have recent CMake)
RUN cmake --version

# Set up Python 3 as default (Ubuntu 24.04 uses Python 3.12)
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3 1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3 1

# Install latest pip
RUN python3 -m pip install --upgrade pip

# Verify Docker CLI is available
RUN docker --version

# Verify key installations
RUN python3 --version \
    && pip --version \
    && docker --version \
    && git --version

# Set default command
CMD ["/bin/bash"]
