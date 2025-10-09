// Example Astro configuration for use with binserve
// IMPORTANT: Binserve only supports static output mode
// Compatible with Astro 5.14.3
import { defineConfig } from 'astro/config';

export default defineConfig({
  // REQUIRED: Must be 'static' for binserve
  // DO NOT USE: 'server' or 'hybrid' (they require Node.js runtime)
  output: 'static',
  
  // RECOMMENDED: Directory format for cleaner URLs
  build: {
    format: 'directory'
  },
  
  // Optional: Set base path if not serving from root
  // base: '/my-app',
  
  // Optional: Custom output directory (default is 'dist')
  // outDir: './dist',
  
  // Optional: Site URL for canonical URLs and sitemap
  // site: 'https://example.com',
  
  // Note: All pages will be pre-rendered at build time
  // For dynamic content, use client-side JavaScript or build-time data fetching
  
  // Binserve serves your 404.html automatically
  // Just create src/pages/404.astro
});

