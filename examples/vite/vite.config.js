// Example Vite configuration for use with binserve
// Works with React, Vue, Svelte, and vanilla JS
// Compatible with Vite 6.x+

import { defineConfig } from 'vite';
// import react from '@vitejs/plugin-react';  // Uncomment for React
// import vue from '@vitejs/plugin-vue';      // Uncomment for Vue

export default defineConfig({
  // plugins: [react()],  // Uncomment for React
  // plugins: [vue()],    // Uncomment for Vue
  
  // Vite builds to 'dist/' directory by default
  // which works perfectly with binserve
  build: {
    outDir: 'dist',
  },
  
  // Optional: Set base path if not serving from root
  // base: '/my-app/',
  
  // Note: All content is pre-rendered at build time
  // Binserve serves static files only
});

// See README.md for examples with other frameworks:
// Astro, Hugo, Next.js, Gatsby, Eleventy, Jekyll, MkDocs, etc.

