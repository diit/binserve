// Example Gatsby configuration for use with binserve
// Binserve works with standard Gatsby builds
// Compatible with Gatsby 5.x+

module.exports = {
  siteMetadata: {
    title: 'My Gatsby Site',
    description: 'A Gatsby site served with binserve',
    siteUrl: 'https://example.com',
  },
  
  // Gatsby builds to 'public/' directory by default
  // which works perfectly with binserve
  
  plugins: [
    // Your plugins here
  ],
  
  // Optional: Configure path prefix if not serving from root
  // pathPrefix: '/my-app',
};

// Note: Gatsby generates fully static HTML by default
// Binserve serves your 404.html automatically
// Just create src/pages/404.js

