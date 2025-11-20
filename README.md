# Binserve Container Image

**Prebuilt, minimal, and production-ready container image** for
[binserve](https://github.com/mufeedvh/binserve) - the blazing-fast static
file server written in Rust.

This image provides a secure, distroless container optimized for serving
static sites from **any framework**: Astro, Hugo, Next.js, Gatsby, Vite,
Eleventy, Jekyll, MkDocs, and more.

## Why This Image?

- 🪶 **Tiny footprint** - Distroless base with statically-linked binary
- ⚡ **Blazing fast** - Rust-powered binserve with zero overhead
- 🔒 **Production-hardened** - Non-root user, read-only filesystem, SLSA attestations
- 🎯 **Framework-agnostic** - Works with any static site generator
- 🏗️ **Multi-arch** - Supports amd64 and arm64

## Quick Start

```dockerfile
# Multi-stage build
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies and build your site
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Runtime with binserve
FROM ghcr.io/diit/binserve:v0.2.0

# Copy built site (adjust source path for your framework)
COPY --from=builder /app/dist /app/public/
```

```bash
docker build -t my-site .
docker run -p 3000:3000 my-site
```

## Framework-Specific Examples

### Astro

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM ghcr.io/diit/binserve:v0.2.0
COPY --from=builder /app/dist /app/public/
```

Astro config requirements:

```javascript
// astro.config.mjs
export default defineConfig({
  output: 'static'  // Required - SSR not supported
});
```

> **See [examples/astro/](examples/astro/) for complete Astro configuration and Dockerfile**

### Hugo

```dockerfile
FROM floryn90/hugo:0.139.3-ext-alpine AS builder
WORKDIR /app
COPY . .
RUN hugo --minify

FROM ghcr.io/diit/binserve:v0.2.0
COPY --from=builder /app/public /app/public/
```

> **See [examples/hugo/](examples/hugo/) for complete Hugo configuration and Dockerfile**

### Next.js (Static Export)

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM ghcr.io/diit/binserve:v0.2.0
COPY --from=builder /app/out /app/public/
```

Next.js config requirements:

```javascript
// next.config.js
module.exports = {
  output: 'export'  // Required for static export
};
```

> **See [examples/nextjs/](examples/nextjs/) for complete Next.js configuration and Dockerfile**

### Gatsby

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM ghcr.io/diit/binserve:v0.2.0
COPY --from=builder /app/public /app/public/
```

> **See [examples/gatsby/](examples/gatsby/) for complete Gatsby configuration and Dockerfile**

### Vite / React / Vue

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM ghcr.io/diit/binserve:v0.2.0
COPY --from=builder /app/dist /app/public/
```

> **See [examples/vite/](examples/vite/) for complete Vite configuration and Dockerfile**

### Eleventy (11ty)

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npx @11ty/eleventy

FROM ghcr.io/diit/binserve:v0.2.0
COPY --from=builder /app/_site /app/public/
```

> **See [examples/eleventy/](examples/eleventy/) for complete Eleventy configuration and Dockerfile**

### Jekyll

```dockerfile
FROM ruby:3.3-alpine AS builder
WORKDIR /app
RUN apk add --no-cache build-base
COPY Gemfile* ./
RUN bundle install
COPY . .
RUN bundle exec jekyll build

FROM ghcr.io/diit/binserve:v0.2.0
COPY --from=builder /app/_site /app/public/
```

> **See [examples/jekyll/](examples/jekyll/) for complete Jekyll configuration and Dockerfile**

### MkDocs

```dockerfile
FROM python:3.12-alpine AS builder
WORKDIR /app
RUN pip install mkdocs-material
COPY . .
RUN mkdocs build

FROM ghcr.io/diit/binserve:v0.2.0
COPY --from=builder /app/site /app/public/
```

> **See [examples/mkdocs/](examples/mkdocs/) for complete MkDocs configuration and Dockerfile**

## Complete Framework Examples

For detailed configuration examples and Dockerfiles for each framework, see
the **[examples/](examples/)** directory:

- [Astro](examples/astro/)
- [Hugo](examples/hugo/)
- [Next.js](examples/nextjs/)
- [Gatsby](examples/gatsby/)
- [Vite (React/Vue/Svelte)](examples/vite/)
- [Eleventy](examples/eleventy/)
- [Jekyll](examples/jekyll/)
- [MkDocs](examples/mkdocs/)

## Kustomize Example

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - deployment.yaml
  - service.yaml

images:
  - name: my-site
    newName: ghcr.io/diit/my-site
    newTag: 1.0.0
```

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: static-site
spec:
  replicas: 2
  selector:
    matchLabels:
      app: static-site
  template:
    metadata:
      labels:
        app: static-site
    spec:
      containers:
      - name: web
        image: my-site
        ports:
        - containerPort: 3000
        resources:
          requests:
            memory: 64Mi
            cpu: 100m
          limits:
            memory: 256Mi
            cpu: 500m
        securityContext:
          runAsNonRoot: true
          runAsUser: 65532
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
```

```yaml
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: static-site
spec:
  selector:
    app: static-site
  ports:
  - port: 80
    targetPort: 3000
```

```bash
kubectl apply -k .
```

## Image Details

- Base: Google Distroless (static-debian12:nonroot)
- User: UID 65532 (non-root)
- Architectures: amd64, arm64

## Configuration

Default port is 3000, content directory is `/app/public/`. You can override `binserve.json`:

```dockerfile
FROM ghcr.io/diit/binserve:v0.2.0
COPY ./dist /app/public/
COPY ./binserve.json /app/binserve.json
```

See [binserve.example.json](binserve.example.json) for available configuration options.

## Local Development & Testing

This project uses [devenv](https://devenv.sh/) for a reproducible development
environment with all necessary tools.

### Development Environment

```bash
# Enter the development environment
devenv shell

# View available commands
info
```

### Testing with Earthly (Recommended)

Earthly provides the closest match to the CI environment:

```bash
# Run tests only
earthly +test

# Build for your current architecture (faster for testing)
earthly +binserve

# Build for multiple platforms (same as CI)
earthly +all-platforms

# Build without pushing (simulates PR workflow)
earthly --ci +all-platforms
```

### Testing GitHub Actions Locally with act

Test the full CI/CD pipeline locally before pushing:

```bash
# Dry run - see what would execute without running
act-dry
# or: act push -n

# Run just the build-and-test job
act-build
# or: act push -j build-and-test

# Run the entire workflow (all jobs)
act-full
# or: act push

# List all available workflows
act -l

# Run a specific event type
act pull_request
```

#### act Configuration

When running act for the first time, you'll be prompted to select a Docker
image size:

- **Recommended**: Medium (used by most GitHub Actions runners)
- Large includes more tools but is slower

Common act options:

```bash
# Use specific runner image
act push --container-architecture linux/amd64

# Pass secrets (for registry login)
act push --secret GITHUB_TOKEN=$GITHUB_TOKEN

# Verbose output for debugging
act push -v

# Run only specific jobs
act push -j build-and-test -j security-scan
```

#### Limitations of act

- Some GitHub-specific features may not work identically (attestations,
  specific action versions)
- Registry push operations should be tested carefully or use `--dry-run`
- For the most accurate testing, use Earthly commands which match CI
  exactly

### Available devenv Commands

```bash
build        # Build container images locally
build-push   # Build and push to registry (requires authentication)
test         # Run test suite
scan         # Security scan with Trivy
act-dry      # Simulate GitHub Actions (dry run)
act-build    # Run build-and-test job locally
act-full     # Run full workflow locally
info         # Show this help and version info
```

## Security

- Trivy scans on every build
- SBOM included with releases (SPDX format)
- SLSA build provenance attestations
- GitHub Actions pinned to commit SHAs
- Distroless base image (no shell/package manager)
- Runs as non-root (UID 65532)
- Read-only filesystem compatible
- Statically linked binary

Verify image:

```bash
gh attestation verify oci://ghcr.io/diit/binserve:v0.2.0 -o diit
```

## License

MIT License - see [binserve LICENSE](https://github.com/mufeedvh/binserve/blob/master/LICENSE)
