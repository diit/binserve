{ pkgs, lib, config, inputs, ... }:

{
  # https://devenv.sh/basics/
  env.GREET = "devenv";
  
  # Environment variables
  env.EARTHLY_ALLOW_PRIVILEGED = "true";
  env.REGISTRY = "ghcr.io";

  # https://devenv.sh/packages/
  packages = with pkgs; [
    # Version control
    git
    
    # Build tools
    earthly
    docker
    
    # Testing and debugging
    curl          # HTTP client
    act           # Run GitHub Actions locally
  ];

  # https://devenv.sh/scripts/
  scripts.build.exec = ''
    echo "Building container images with Earthly..."
    earthly +binserve
  '';
  
  scripts.build-push.exec = ''
    echo "Building and pushing container images..."
    earthly --push +binserve
  '';
  
  scripts.test.exec = ''
    echo "Running tests..."
    earthly +test
  '';
  
  scripts.scan.exec = ''
    echo "Scanning image for vulnerabilities..."
    IMAGE_TAG=$(grep 'ARG --global BINSERVE_VERSION=' Earthfile | cut -d'=' -f2)
    trivy image ghcr.io/diit/binserve:''${IMAGE_TAG}
  '';
  
  scripts.act-dry.exec = ''
    echo "Simulating GitHub Actions workflow (dry run)..."
    act push -n
  '';
  
  scripts.act-build.exec = ''
    echo "Running build-and-test job locally with act..."
    act push -j build-and-test
  '';
  
  scripts.act-full.exec = ''
    echo "Running full GitHub Actions workflow locally..."
    act push
  '';
  
  scripts.info.exec = ''
    BINSERVE_VERSION=$(grep 'ARG --global BINSERVE_VERSION=' Earthfile | cut -d'=' -f2 2>/dev/null || echo "unknown")
    ASTRO_VERSION=$(grep 'ARG --global ASTRO_VERSION=' Earthfile | cut -d'=' -f2 2>/dev/null || echo "unknown")
    HUGO_VERSION=$(grep 'ARG --global HUGO_VERSION=' Earthfile | cut -d'=' -f2 2>/dev/null || echo "unknown")
    NEXTJS_VERSION=$(grep 'ARG --global NEXTJS_VERSION=' Earthfile | cut -d'=' -f2 2>/dev/null || echo "unknown")
    
    echo "Binserve - Development Environment"
    echo "==================================="
    echo ""
    echo "Available commands:"
    echo "  build       - Build container images locally"
    echo "  build-push  - Build and push to registry"
    echo "  test        - Run test suite"
    echo "  scan        - Security scan with Trivy"
    echo "  act-dry     - Simulate GitHub Actions (dry run)"
    echo "  act-build   - Run build-and-test job locally"
    echo "  act-full    - Run full workflow locally"
    echo ""
    echo "Image details:"
    echo "  Binserve version: ''${BINSERVE_VERSION}"
    echo "  Architectures: amd64, arm64"
    echo ""
    echo "Tested with:"
    echo "  Astro: ''${ASTRO_VERSION}"
    echo "  Hugo: ''${HUGO_VERSION}"
    echo "  Next.js: ''${NEXTJS_VERSION}"
    echo ""
    echo "Documentation: README.md"
  '';

  # https://devenv.sh/pre-commit-hooks/
  git-hooks.hooks = {
    markdownlint.enable = true;
    shellcheck.enable = true;
  };

  # See full reference at https://devenv.sh/reference/options/
}
