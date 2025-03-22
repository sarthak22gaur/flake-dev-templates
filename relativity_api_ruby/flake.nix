{
  description = "A Nix-flake-based Ruby development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          packages = with pkgs; [ ruby_3_3 bundler libpq postgresql redis libxml2 libxslt zlib gcc xz libyaml ];
          shellHook = ''
            # Ensure Bundler installs gems into this project's vendor/bundle directory
            export BUNDLE_PATH="$PWD/vendor/bundle"
            export GEM_HOME="$BUNDLE_PATH"
            export GEM_PATH="$BUNDLE_PATH"
            export BUNDLE_BIN="$BUNDLE_PATH/bin"
            export PATH="$BUNDLE_BIN:$PATH"

            # Retrieve and set GitHub credentials dynamically
            GITHUB_PAT=$(pass $RUBY_PAT_DIR)
            bundle config rubygems.pkg.github.com "$GITHUB_USERNAME:$GITHUB_PAT"
          '';
        };
      });
    };
}
