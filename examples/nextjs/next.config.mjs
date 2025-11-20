// Example Next.js configuration for use with binserve
// IMPORTANT: Binserve only supports static export mode
// Compatible with Next.js 15.0.0+

/** @type {import('next').NextConfig} */
const nextConfig = {
  // REQUIRED: Must be 'export' for binserve
  // This generates a static site in the 'out' directory
  output: 'export',
  
  // Optional: Disable image optimization for static export
  // (or use next/image's unoptimized prop)
  images: {
    unoptimized: true,
  },
  
  // Optional: Set base path if not serving from root
  // basePath: '/my-app',
  
  // Optional: Set trailing slashes for URLs
  trailingSlash: true,
  
  // Note: API routes and server-side rendering are not supported
  // All pages will be pre-rendered at build time
};

export default nextConfig;

// See README.md for examples with other frameworks:
// Astro, Hugo, Gatsby, Vite, Eleventy, Jekyll, MkDocs, etc.

