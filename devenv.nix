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
    
    # Container inspection and security
    dive          # Docker image analysis
    trivy         # Vulnerability scanner
    
    # JSON/YAML processing
    jq            # JSON processor
    yq-go         # YAML processor
    
    # Testing and debugging
    curl          # HTTP client
    httpie        # Modern HTTP client
    
    # Documentation
    markdownlint-cli  # Markdown linting
    
    # Optional: Kubernetes tools (comment out if not needed)
    kubectl
    kubernetes-helm
  ];

  # https://devenv.sh/scripts/
  scripts.build.exec = ''
    echo "Building container images with Earthly..."
    earthly +astro
  '';
  
  scripts.build-push.exec = ''
    echo "Building and pushing container images..."
    earthly --push +astro
  '';
  
  scripts.test.exec = ''
    echo "Running tests..."
    earthly +test
  '';
  
  scripts.scan.exec = ''
    echo "Scanning image for vulnerabilities..."
    IMAGE_TAG=$(grep 'ARG --global ASTRO_VERSION=' Earthfile | cut -d'=' -f2)
    trivy image ghcr.io/diit/binserve:astro-v$${IMAGE_TAG}
  '';
  
  scripts.info.exec = ''
    ASTRO_VERSION=$(grep 'ARG --global ASTRO_VERSION=' Earthfile | cut -d'=' -f2 2>/dev/null || echo "unknown")
    BINSERVE_VERSION=$(grep 'ARG --global BINSERVE_VERSION=' Earthfile | cut -d'=' -f2 2>/dev/null || echo "unknown")
    
    echo "Binserve for Astro - Development Environment"
    echo "=============================================="
    echo ""
    echo "Available commands:"
    echo "  build       - Build container images locally"
    echo "  build-push  - Build and push to registry"
    echo "  test        - Run test suite"
    echo "  scan        - Security scan with Trivy"
    echo ""
    echo "Image details:"
    echo "  Astro version: $${ASTRO_VERSION}"
    echo "  Binserve version: $${BINSERVE_VERSION}"
    echo "  Architectures: amd64, arm64"
    echo ""
    echo "Documentation: README.md"
  '';

  # https://devenv.sh/languages/
  # Uncomment if you need Rust for local binserve development
  # languages.rust.enable = true;
  # languages.rust.channel = "stable";

  # https://devenv.sh/pre-commit-hooks/
  pre-commit.hooks = {
    markdownlint.enable = true;
    shellcheck.enable = true;
  };

  # https://devenv.sh/processes/
  # processes.docker.exec = "docker daemon";

  # See full reference at https://devenv.sh/reference/options/
}
