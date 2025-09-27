{
  description = "A Nix-flake-based Bun development environment";

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
            lua-language-server    # lua_ls
            pyright               # Python
            typescript-language-server  # TypeScript/JavaScript
            rust-analyzer         # Rust
            gopls                # Go

            # Formatters/Linters (optional)
            stylua               # Lua formatter
            black                # Python formatter
            prettierd            # JS/TS formatter
          ];
        };
      });
    };
}
