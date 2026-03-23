{
  description = "A Nix-flake-based QoL packages";

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
            # Data/text processing
            cloc
            csvkit
            jq
            yq
            miller
            tabview

            # File/system utilities
            tree
            tokei
            dust
            duf
            hyperfine

            # Networking
            curlie
            xh
          ];
        };
      });
    };
}

