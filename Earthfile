VERSION 0.8

# Build arguments
ARG --global BINSERVE_VERSION=v0.2.0
ARG --global ASTRO_VERSION=5.14.3
ARG --global REGISTRY=ghcr.io
ARG --global REPO=diit/binserve

# Base image for building binserve
binserve-binary:
    FROM rust:1.83-alpine
    WORKDIR /build
    
    # Install build dependencies
    RUN apk add --no-cache git musl-dev openssl-dev openssl-libs-static pkgconfig
    
    # Clone and build binserve
    RUN git clone https://github.com/mufeedvh/binserve.git .
    ARG BINSERVE_VERSION=v0.2.0
    RUN git checkout ${BINSERVE_VERSION}
    
    # Determine target architecture
    ARG TARGETARCH
    RUN case "${TARGETARCH}" in \
        amd64) echo "x86_64-unknown-linux-musl" > /tmp/target ;; \
        arm64) echo "aarch64-unknown-linux-musl" > /tmp/target ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
        esac
    
    # Add rust target and build with full static linking
    RUN TARGET=$(cat /tmp/target) && \
        rustup target add $TARGET && \
        OPENSSL_STATIC=1 \
        OPENSSL_LIB_DIR=/usr/lib \
        OPENSSL_INCLUDE_DIR=/usr/include \
        PKG_CONFIG_ALL_STATIC=1 \
        RUSTFLAGS="-C target-feature=+crt-static" \
        cargo build --release --target $TARGET
    
    # Save the binary (location depends on architecture)
    RUN TARGET=$(cat /tmp/target) && \
        cp /build/target/$TARGET/release/binserve /build/binserve
    SAVE ARTIFACT /build/binserve /binserve

# Create binserve configuration for Astro
config:
    FROM alpine:latest
    WORKDIR /config
    
    # Copy the production-ready configuration from the repository
    # This is cleaner than generating JSON inline and easier to maintain
    COPY binserve.example.json binserve.json
    
    SAVE ARTIFACT binserve.json /binserve.json

# Test stage - validates the build
test:
    FROM alpine:latest
    
    # Install testing tools
    RUN apk add --no-cache jq file
    
    # Copy artifacts to test
    COPY +binserve-binary/binserve /tmp/binserve
    COPY +config/binserve.json /tmp/binserve.json
    
    # Create HTML files
    RUN mkdir -p /tmp/public
    RUN echo '<html><body><h1>Test Page</h1></body></html>' > /tmp/public/index.html
    RUN echo '<html><body><h1>404 - Not Found</h1></body></html>' > /tmp/public/404.html
    RUN echo '<html><body><h1>500 - Server Error</h1></body></html>' > /tmp/public/500.html
    
    # Verify binary is executable
    RUN chmod +x /tmp/binserve
    RUN /tmp/binserve --version || echo "binserve binary OK"
    
    # Validate JSON is syntactically correct
    RUN jq empty /tmp/binserve.json || (echo "Invalid JSON configuration" && exit 1)

# Astro image - distroless for maximum security
astro:
    # Run tests first to ensure build is valid
    BUILD +test
    
    # Use distroless static image (no libc, just static binaries)
    FROM gcr.io/distroless/static-debian12:nonroot
    
    WORKDIR /app
    
    # Copy binserve binary directly (static binary, no dependencies needed)
    COPY +binserve-binary/binserve /usr/local/bin/binserve
    
    # Copy configuration directly
    COPY +config/binserve.json /app/binserve.json
    
    # NOTE: /app/public/ directory will be created automatically when users
    # COPY their dist folder in their Dockerfiles. Distroless images are
    # immutable and don't support RUN commands (no shell, no package manager).
    
    # Add labels
    ARG ASTRO_VERSION=5.14.3
    ARG BINSERVE_VERSION=v0.2.0
    ARG REGISTRY=ghcr.io
    ARG REPO=diit/binserve
    LABEL astro.version=${ASTRO_VERSION}
    LABEL astro.mode="static"
    LABEL binserve.version=${BINSERVE_VERSION}
    LABEL org.opencontainers.image.description="Distroless binserve container for Astro ${ASTRO_VERSION} static sites"
    LABEL org.opencontainers.image.base.name="gcr.io/distroless/static-debian12:nonroot"
    LABEL org.opencontainers.image.source="https://github.com/diit/binserve"
    LABEL org.opencontainers.image.licenses="MIT"
    
    # Distroless runs as nonroot user (UID 65532, GID 65532) by default
    # Our files are owned by root but readable by all
    
    # Expose port
    EXPOSE 8080
    
    # No health check - distroless has no shell/wget
    # K8s should use httpGet probes instead
    
    # Run binserve
    ENTRYPOINT ["/usr/local/bin/binserve"]
    CMD ["-c", "/app/binserve.json"]
    
    # Save images with proper registry configuration
    SAVE IMAGE binserve:astro-v${ASTRO_VERSION}
    SAVE IMAGE --push ${REGISTRY}/${REPO}:astro-v${ASTRO_VERSION}

