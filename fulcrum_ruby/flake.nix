{
  description = "A Nix-flake-based Ruby development environment";

  # Use nixos-unstable for most packages
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  # Pin nixpkgs to a revision that provides Ruby 3.3.0 (required by Fulcrum)
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
            (rubyPkgs.ruby_3_3)
            libpq postgresql redis libxml2 libxslt zlib gcc xz libyaml
            pkg-config
            openssl
          ];
          shellHook = ''
            # Ensure Bundler installs gems into this project's vendor/bundle directory
            export BUNDLE_PATH="$PWD/vendor/bundle"
            export GEM_HOME="$BUNDLE_PATH"
            export GEM_PATH="$BUNDLE_PATH"
            export BUNDLE_BIN="$BUNDLE_PATH/bin"
            export PATH="$BUNDLE_BIN:$PATH"

            # Native gem build flags
            export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
            export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig:${pkgs.libpq.dev or pkgs.libpq}/lib/pkgconfig:${pkgs.libyaml.dev or pkgs.libyaml}/lib/pkgconfig:$PKG_CONFIG_PATH"
            export LDFLAGS="-L${pkgs.openssl.out}/lib -L${pkgs.libpq.out or pkgs.libpq}/lib"
            export CPPFLAGS="-I${pkgs.openssl.dev}/include -I${pkgs.libpq.dev or pkgs.libpq}/include"
            export OPENSSL_DIR="${pkgs.openssl.dev}"
            export YAML_DIR="${pkgs.libyaml.dev or pkgs.libyaml}/lib"

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
