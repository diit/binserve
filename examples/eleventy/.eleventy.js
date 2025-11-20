// Example Eleventy (11ty) configuration for use with binserve
// Compatible with Eleventy 3.x+

module.exports = function(eleventyConfig) {
  // Eleventy builds to '_site/' directory by default
  // You can change this if needed:
  // return {
  //   dir: {
  //     input: "src",
  //     output: "dist"
  //   }
  // };
  
  // Copy static assets
  eleventyConfig.addPassthroughCopy("assets");
  eleventyConfig.addPassthroughCopy("images");
  
  // Binserve serves your 404.html automatically
  // Just create 404.njk (or 404.md, 404.html, etc.)
  
  return {
    dir: {
      input: "src",
      output: "_site",
      includes: "_includes",
      layouts: "_layouts"
    },
    
    // Optional: Set path prefix if not serving from root
    // pathPrefix: "/my-app/",
    
    templateFormats: ["md", "njk", "html"],
    markdownTemplateEngine: "njk",
    htmlTemplateEngine: "njk"
  };
};

// See README.md for examples with other frameworks:
// Astro, Hugo, Next.js, Gatsby, Vite, Jekyll, MkDocs, etc.

