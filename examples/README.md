# Binserve - Framework Examples

This directory contains example configurations and Dockerfiles for deploying
static sites with binserve. Binserve works with **any static site generator**.
These examples show you exactly how to configure popular frameworks.

## 📁 Directory Structure

```text
examples/
├── astro/           # Astro example
│   ├── astro.config.mjs
│   └── Dockerfile
├── hugo/            # Hugo example
│   ├── config.toml
│   └── Dockerfile
├── nextjs/          # Next.js (static export) example
│   ├── next.config.mjs
│   └── Dockerfile
├── gatsby/          # Gatsby example
│   ├── gatsby-config.js
│   └── Dockerfile
├── vite/            # Vite (React/Vue/Svelte) example
│   ├── vite.config.js
│   └── Dockerfile
├── eleventy/        # Eleventy (11ty) example
│   ├── .eleventy.js
│   └── Dockerfile
├── jekyll/          # Jekyll example
│   ├── _config.yml
│   └── Dockerfile
└── mkdocs/          # MkDocs example
    ├── mkdocs.yml
    └── Dockerfile
```

## 🚀 Quick Start

Each framework directory contains:

1. **Configuration file** - Framework-specific config with binserve-compatible settings
2. **Dockerfile** - Multi-stage build example for containerization

### Usage

1. Choose your framework from the examples above
2. Copy the configuration file to your project root
3. Copy the Dockerfile to your project root
4. Build and run:

```bash
docker build -t my-site .
docker run -p 3000:3000 my-site
```

## 📦 Framework Output Directories

Each framework builds to a different output directory. Here's the mapping:

| Framework | Output Directory | Copy Command in Dockerfile |
|-----------|-----------------|---------------------------|
| Astro     | `dist/`         | `COPY --from=builder /app/dist /app/public/` |
| Hugo      | `public/`       | `COPY --from=builder /app/public /app/public/` |
| Next.js   | `out/`          | `COPY --from=builder /app/out /app/public/` |
| Gatsby    | `public/`       | `COPY --from=builder /app/public /app/public/` |
| Vite      | `dist/`         | `COPY --from=builder /app/dist /app/public/` |
| Eleventy  | `_site/`        | `COPY --from=builder /app/_site /app/public/` |
| Jekyll    | `_site/`        | `COPY --from=builder /app/_site /app/public/` |
| MkDocs    | `site/`         | `COPY --from=builder /app/site /app/public/` |

## 🔧 Important Notes

### Static-Only Requirements

Binserve serves **static files only**. This means:

- ✅ **Supported**: Pre-rendered HTML, CSS, JavaScript, images, fonts
- ❌ **Not supported**: Server-side rendering (SSR), API routes, dynamic backends

### Framework-Specific Requirements

**Astro**: Must use `output: 'static'` (not `'server'` or `'hybrid'`)

**Next.js**: Must use `output: 'export'` in `next.config.js`

**Hugo/Gatsby/Jekyll/MkDocs**: Work out of the box (already static)

**Vite**: Already static, works with React, Vue, Svelte, or vanilla JS

**Eleventy**: Already static by design

### Custom Configuration

All examples use the default binserve configuration:

- Port: 3000
- Directory: `/app/public/`
- Logging: Enabled

To customize, copy `binserve.example.json` from the project root to your
project and modify as needed:

```dockerfile
FROM ghcr.io/diit/binserve:v0.2.0
COPY ./dist /app/public/
COPY ./binserve.json /app/binserve.json
```

## 🎯 Missing Your Framework?

Binserve works with **any** static site generator. If your framework isn't
listed:

1. Find where your framework outputs built files (usually `dist/`, `build/`,
   or `public/`)
2. Use the generic Dockerfile pattern:

```dockerfile
FROM your-builder AS builder
WORKDIR /app
# ... install dependencies and build ...

FROM ghcr.io/diit/binserve:v0.2.0
COPY --from=builder /app/YOUR_OUTPUT_DIR /app/public/
```

1. That's it!

## 📚 Learn More

- [Main README](../README.md) - Full documentation
- [binserve GitHub](https://github.com/mufeedvh/binserve) - Upstream binserve project
- [Configuration Options](../binserve.example.json) - Example binserve config

## 🤝 Contributing

Found an issue with an example? Have a suggestion? Please open an issue or PR!
