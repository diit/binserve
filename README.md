# Binserve for Astro

Pre-built container image for hosting Astro static sites using [binserve](https://github.com/mufeedvh/binserve).

This image only supports Astro's `output: 'static'` mode. SSR and Hybrid modes require Node.js and are not compatible.

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

Build and run:

```bash
docker build -t my-astro-site .
docker run -p 8080:8080 my-astro-site
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
        - containerPort: 8080
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
    targetPort: 8080
```

Deploy:

```bash
kubectl apply -k .
```

## Configuration

Default settings:
- Port: 8080
- Content directory: `/app/public/`
- Base image: Google Distroless (static-debian12:nonroot)
- User: Non-root (UID 65532)
- Architectures: amd64, arm64

To customize, provide your own `binserve.json`:

```dockerfile
FROM ghcr.io/diit/binserve:astro-v5.14.3

COPY ./dist /app/public/
COPY ./binserve.json /app/binserve.json
```

## Astro Configuration

Set static output mode in `astro.config.mjs`:

```javascript
import { defineConfig } from 'astro/config';

export default defineConfig({
  output: 'static'
});
```

## License

MIT License - see [binserve LICENSE](https://github.com/mufeedvh/binserve/blob/master/LICENSE)
