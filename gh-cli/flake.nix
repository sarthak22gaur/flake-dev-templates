{
  description = "A Nix-flake-based Github CLI development environment";

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
          packages = with pkgs; [
            gh
            pass
          ];

          shellHook = ''
            # Expect RUBY_PAT_DIR to be set by direnv or your shell
            # e.g. export RUBY_PAT_DIR="work/github/rubygems-pat"
            if [ -n "$GH_TOKEN_DIR" ]; then
              GH_TOKEN="$(pass "$GH_TOKEN_DIR")"
              GITHUB_TOKEN="$(pass "$GH_TOKEN_DIR")"
              export GH_TOKEN
              export GITHUB_TOKEN
            else
              echo "GH_TOKEN_DIR is not set; cannot load GH_TOKEN from pass" >&2
            fi
          '';
        };
      });
    };
}
