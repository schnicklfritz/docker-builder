# Docker Builder - Universal CUDA 12.8 Builder Image

Universal CUDA 12.8 builder image for AI/ML project builds on QuickPod.

## Overview

This Docker image provides a complete build environment for AI/ML projects on QuickPod, featuring:

### What's Inside
- **Base**: NVIDIA CUDA 12.8 development environment on Ubuntu 22.04
- **Docker Tools**: Docker CLI, Docker Buildx plugin, Docker Compose
- **Build Toolchain**: gcc, g++, make, cmake (≥3.25), ninja-build, pkg-config
- **Python**: Python 3.12 with pip, python3-dev, python3-venv, build-essential
- **Git**: Git, git-lfs, GitHub CLI
- **Media**: FFmpeg with CUDA NVENC/NVDEC support
- **Audio**: sox, libsndfile1-dev, libportaudio2, libasound2-dev, libpulse-dev
- **Image**: libjpeg-dev, libpng-dev, libtiff-dev
- **Network**: libssl-dev, libcurl4-openssl-dev
- **Compression**: zlib1g-dev, liblzma-dev
- **Math**: libopenblas-dev, liblapack-dev
- **Utilities**: curl, wget, unzip, jq, vim, nano, htop

### What's Excluded
- PyTorch or TensorFlow (installed per-project with registry cache)
- Docker Engine/daemon (QuickPod host provides this via socket mounting)
- Desktop environment or VNC (web-based UIs work via port forwarding)
- Application code or models

**Target size**: Less than 5GB compressed

## Image Location

Available on Docker Hub: `schnicklbob/docker-builder:latest`

## QuickPod Usage Template

### Complete Docker Run Command

```bash
docker run -it --rm \
  --gpus all \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd):/workspace \
  -p 8188:8188 \
  -p 7860:7860 \
  -p 3000:3000 \
  -e DOCKERHUB_USERNAME="your-dockerhub-username" \
  -e DOCKERHUB_TOKEN="your-dockerhub-token" \
  -e GITHUB_TOKEN="your-github-token" \
  schnicklbob/docker-builder:latest
```

### Environment Variables for Registry Authentication

Inside the container, authenticate to registries:

```bash
# Docker Hub
echo "$DOCKERHUB_TOKEN" | docker login --username "$DOCKERHUB_USERNAME" --password-stdin

# GitHub Container Registry
echo "$GITHUB_TOKEN" | docker login ghcr.io --username your-github-username --password-stdin
```

### Building Projects with Registry Cache

Use Docker Buildx with registry caching for fast builds:

```bash
# Set up buildx with registry cache
docker buildx create --name builder --driver docker-container --use
docker buildx inspect --bootstrap

# Build with registry caching
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --cache-from type=registry,ref=ghcr.io/your-org/your-project:buildcache \
  --cache-to type=registry,ref=ghcr.io/your-org/your-project:buildcache,mode=max \
  -t your-image:latest \
  --push .
```

## Web UI Access

Web-based UIs are accessed via QuickPod IP and port number:

- **ComfyUI**: `http://<quickpod-ip>:8188`
- **Gradio Apps**: `http://<quickpod-ip>:7860` 
- **Silly Tavern**: `http://<quickpod-ip>:3000`

No VNC needed - all interfaces work directly through web browsers.

## Registry Caching Benefits

### How It Works
- PyTorch and large dependencies are cached across builds and QuickPod sessions
- First build downloads large files (PyTorch, CUDA libraries, etc.)
- Subsequent builds pull from cache in seconds
- Cache persists between QuickPod sessions via GitHub Container Registry

### Performance Impact
- **First build**: Downloads ~2-3GB of dependencies
- **Subsequent builds**: Uses cached layers (~30 seconds)
- **Cross-session builds**: Maintains cache across QuickPod instances

## Compatible Projects

### Works Great With
- **ComfyUI**: AI workflow automation
- **Gradio Apps**: Interactive ML demos
- **Ollama**: Local LLM deployment
- **Silly Tavern**: Character AI interface
- **Custom ML Models**: PyTorch, TensorFlow, JAX
- **Audio Processing**: SoX, FFmpeg workflows
- **Image Processing**: OpenCV, PIL applications

### Needs Separate Desktop Variant
- **Native GUI Apps**: Reaper DAW, Blender, GIMP
- **Desktop Applications**: Require X11/VNC forwarding
- **Real-time Audio**: May need direct ALSA/PulseAudio access

## Hardware Compatibility

### QuickPod GPU Support
- **Entry Level**: GTX 1660 Ti, RTX 2060
- **Mid Range**: RTX 3060, RTX 4060
- **High End**: RTX 3080, RTX 4080
- **Professional**: RTX 4090, RTX 5090

### CUDA Compatibility
- **Runtime**: CUDA 12.8 backward compatible to 11.x
- **Driver**: Requires NVIDIA driver 525.60.13 or later
- **Compute**: Supports compute capability 5.0+

## Development Workflow

1. **Start Container** with GPU access and Docker socket
2. **Clone Project** into `/workspace`
3. **Authenticate** to Docker Hub and GitHub registries
4. **Build with Cache** using Buildx registry caching
5. **Test Application** with port forwarding for web UIs
6. **Push Images** to registries for deployment

## GitHub Actions

This repository includes automated builds via GitHub Actions:

- **Triggers**: Push to main branch or manual workflow_dispatch
- **Features**: Multi-platform builds, registry caching
- **Output**: Images pushed to Docker Hub with multiple tags
- **Cache**: Build cache stored in GitHub Container Registry

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test builds
4. Submit a pull request

## License

MIT License - see LICENSE file for details
