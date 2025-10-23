# Binserve for Astro

Container image for serving Astro static sites with [binserve](https://github.com/mufeedvh/binserve).

Supports `output: 'static'` only. SSR and Hybrid modes are not supported.

## Docker Example

```dockerfile
# Multi-stage build
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci

# Build Astro site
COPY . .
RUN npm run build

# Runtime with binserve
FROM ghcr.io/diit/binserve:astro-v5.14.3

# Copy built site
COPY --from=builder /app/dist /app/public/
```

```bash
docker build -t my-astro-site .
docker run -p 3000:3000 my-astro-site
```

## Kustomize Example

```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - deployment.yaml
  - service.yaml

images:
  - name: my-astro-site
    newName: ghcr.io/diit/my-astro-site
    newTag: 1.0.0
```

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: astro-site
spec:
  replicas: 2
  selector:
    matchLabels:
      app: astro-site
  template:
    metadata:
      labels:
        app: astro-site
    spec:
      containers:
      - name: web
        image: my-astro-site
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
  name: astro-site
spec:
  selector:
    app: astro-site
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
FROM ghcr.io/diit/binserve:astro-v5.14.3
COPY ./dist /app/public/
COPY ./binserve.json /app/binserve.json
```

## Astro Configuration

`astro.config.mjs`:

```javascript
import { defineConfig } from 'astro/config';

export default defineConfig({
  output: 'static'
});
```

## Security

- Trivy scans on every build (blocks on CRITICAL/HIGH vulnerabilities)
- SBOM included with releases (SPDX format)
- SLSA build provenance attestations
- GitHub Actions pinned to commit SHAs
- Distroless base image (no shell/package manager)
- Runs as non-root (UID 65532)
- Read-only filesystem compatible
- Statically linked binary

Verify image:

```bash
gh attestation verify oci://ghcr.io/diit/binserve:astro-v5.14.3 -o diit
```

## License

MIT License - see [binserve LICENSE](https://github.com/mufeedvh/binserve/blob/master/LICENSE)
