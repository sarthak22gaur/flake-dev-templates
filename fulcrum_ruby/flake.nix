{
  description = "A Nix-flake-based Ruby development environment";

  # Use nixos-unstable for most packages
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  # Pin a separate nixpkgs version for Ruby 3.3.0
  inputs.rubyNixpkgs.url = "github:NixOS/nixpkgs/e89cf1c932006531f454de7d652163a9a5c86668";

  outputs = { self, nixpkgs, rubyNixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
        rubyPkgs = import rubyNixpkgs { inherit system; };
      });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs, rubyPkgs }: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            # Use Ruby 3.3.0 from pinned Ruby-specific nixpkgs
            (rubyPkgs.ruby_3_3)
            # Remove bundler from here as we'll install the specific version
            libpq postgresql redis libxml2 libxslt zlib gcc xz libyaml pkg-config
          ];
          shellHook = ''
            # Ensure Bundler installs gems into this project's vendor/bundle directory
            export BUNDLE_PATH="$PWD/vendor/bundle"
            export GEM_HOME="$BUNDLE_PATH"
            export GEM_PATH="$BUNDLE_PATH"
            export BUNDLE_BIN="$BUNDLE_PATH/bin"
            export PATH="$BUNDLE_BIN:$PATH"

            # Install the specific bundler version
            if ! gem list -i "^bundler$" -v "2.6.6" > /dev/null; then
              echo "Installing bundler 2.6.6..."
              gem install bundler -v 2.6.6
            fi

            # Retrieve and set GitHub credentials dynamically
            GITHUB_PAT=$(pass $RUBY_PAT_DIR)
            bundle config rubygems.pkg.github.com "$GITHUB_USERNAME:$GITHUB_PAT"
          '';
        };
      });
    };
}
